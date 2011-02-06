require 'helper'

class SendEmailTest < Test::Unit::TestCase
  include TestEmailSender

  def test_start
    EM.synchrony {
      SesSmtp::Server.start(config_path)
      EM.stop
    }
  end

  def test_email_simple
    EM.synchrony {
      SesSmtp::Server.start(config_path)
      10.times do
        response = send_plain_to_from("tester@test.com", "tester@example.com", "hello", "hello")
        assert_equal EventMachine::Protocols::SmtpClient, response.class
        assert response.instance_variable_get(:@succeeded)
      end
      SesSmtp::Server.stop
      EM.stop
    }
  end

end
