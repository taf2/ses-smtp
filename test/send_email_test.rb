require 'helper'

class SendEmailTest < Test::Unit::TestCase
  include TestEmailSender

  def test_email_from_to_generic
    EM.synchrony {
      EM.defer { SesSmtp::Server.start('127.0.0.1',TPORT) }
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
