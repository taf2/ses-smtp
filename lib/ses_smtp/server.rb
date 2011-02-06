# -*- encoding: binary -*-
# source originally from: http://rdoc.info/github/eventmachine/eventmachine/master/EventMachine/Protocols/SmtpServer
require 'ostruct'
require 'eventmachine'
require 'ses_smtp/config'
require 'ses_smtp/mailer'

module SesSmtp
  class Server < EM::P::SmtpServer
    def self.config
      @config
    end

    def receive_plain_auth(user, pass)
      true
    end

    def get_server_domain
      Server.config.options.domain || "mock.smtp.server.local"
    end

    def get_server_greeting
      "smtp ses greetings"
    end

    def receive_sender(sender)
      current.sender = sender
      true
    end

    def receive_recipient(recipient)
      current.recipient = recipient
      true
    end

    def receive_message
      current.received = true
      current.completed_at = Time.now

      begin
        SesSmtp::Mailer.new(Server.config).send_email_raw(current)
      rescue => e
        p e
        p [:received_email, current]
      end

      @current = OpenStruct.new
      true
    end

    def receive_ehlo_domain(domain)
      @ehlo_domain = domain
      true
    end

    def receive_data_command
      current.data = ""
      true
    end

    def receive_data_chunk(data)
      current.data << data.join("\n")
      true
    end

    def receive_transaction
      if @ehlo_domain
         current.ehlo_domain = @ehlo_domain
         @ehlo_domain = nil
      end
      true
    end

    def current
      @current ||= OpenStruct.new
    end

    def self.start(config_path)
      @config = Config.new(config_path)

      trap(:HUP)  { reload }
      trap(:QUIT) { stop }

      @server = EM.start_server @config.options.host, @config.options.port, self
    end

    def self.reload
      @config = Config.new(@config.path)
    end

    def self.stop
      if @server
       EM.stop_server @server
       @server = nil
      end
    end

    def self.running?
      !!@server
    end
  end
end
