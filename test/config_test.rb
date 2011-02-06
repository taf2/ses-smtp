require 'helper'

class ConfigTest < Test::Unit::TestCase

  def test_sample_config
    config = SesSmtp::Config.new(TestPath + '/sample_config.rb')
    assert_equal "localhost", config.options.host
    assert_equal 40998, config.options.port
    assert_equal "amazon-access-key", config.options.access_key
    assert_equal "amazon-secret-key", config.options.secret_key
    assert_equal "example.com", config.options.domain
    assert_equal Logger, config.options.logger.class
  end

  def test_broken_config
    error = assert_raise SesSmtp::Config::Error do
      SesSmtp::Config.new(TestPath + '/broken_config.rb')
    end
    assert_match /uninitialized constant SesSmtp::Config::LoggerFooUnknown/, error.message
  end

end
