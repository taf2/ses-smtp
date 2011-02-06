# -*- encoding: binary -*-
require 'test/unit'
require 'thread'
require 'em-synchrony'

TestPath = File.expand_path(File.join(File.dirname(__FILE__)))

$:.unshift File.join(TestPath,'../lib')
require 'ses_smtp'
TPORT=40998

module TestEmailSender

  def send_plain_to_from(to, from, subject, message)
    f = Fiber.current

    email = EM::Protocols::SmtpClient.send :domain   => "example.com",
                                           :host     => 'localhost',
                                           :port     => TPORT,
                                           :starttls => false, # use ssl
                                           :from     => from,
                                           :to       => to,
                                           :header   => {"Subject" => subject},
                                           :body     => message

     email.callback { puts "good" ; f.resume(email) }
     email.errback  { |e| puts "bad" ; f.resume(e) }

     return Fiber.yield
  end

end
