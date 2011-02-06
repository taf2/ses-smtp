
module SesSmtp
  #
  # interface with SES
  #
  class Mailer

    def initialize(config)
      @config = config
    end

    def send_email_raw(message)
    end

  end
end
