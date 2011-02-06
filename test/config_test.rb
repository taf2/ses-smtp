require 'helper'

class ConfigTest < Test::Unit::TestCase

  def test_sample_config
    config = SesSmtp::Config.new(TestPath + '/sample_config.rb')
    puts config.inspect
  end

end
