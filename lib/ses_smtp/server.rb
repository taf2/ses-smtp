# -*- encoding: binary -*-
# source originally from: http://rdoc.info/github/eventmachine/eventmachine/master/EventMachine/Protocols/SmtpServer
require 'ostruct'
require 'eventmachine'
require 'ses_smtp/config'

module SesSmtp
  class Server < EM::P::SmtpServer
    def receive_plain_auth(user, pass)
      true
    end

    def get_server_domain
      "mock.smtp.server.local"
    end

    def get_server_greeting
      "mock smtp server greets you with impunity"
    end

    def receive_sender(sender)
#      puts sender.inspect
      current.sender = sender
      true
    end

    def receive_recipient(recipient)
#      puts recipient.inspect
      current.recipient = recipient
      true
    end

    def receive_message
#      puts "message"
      current.received = true
      current.completed_at = Time.now

      p [:received_email, current]
      @current = OpenStruct.new
      true
    end

    def receive_ehlo_domain(domain)
#      puts "domain:#{domain.inspect}"
      @ehlo_domain = domain
      true
    end

    def receive_data_command
      current.data = ""
      true
    end

    def receive_data_chunk(data)
#      puts "data:#{data.inspect}"
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

      @server = EM.start_server @config.host, @config.port, self
    end

    def self.reload
      @config.reload
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
