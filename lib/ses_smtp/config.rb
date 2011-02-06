require 'ostruct'

module SesSmtp
  #
  # evaluate configuration files to load into server process
  #
  class Config
    attr_reader :options
    
    def initialize(path)
      @config_path = path
      @options = OpenStruct.new {}
    end

    def access_key(key)
      @options[:access_key] = key
    end

    def secret_key(key)
      @options[:secret_key] = key
    end

    def domain(key)
      @options[:domain] = key
    end

    def before_send(&block)
      @options[:before_send] = block
    end

    def after_send(&block)
      @options[:after_send] = block
    end

    def run
      eval(File.read(@config_path), binding)
    end

  end
end
