require 'ostruct'

module SesSmtp
  #
  # evaluate configuration files to load into server process
  #
  class Config

    class Error < Exception
    end

    attr_reader :options, :path
    
    def initialize(path)
      @path = path
      @options = OpenStruct.new {}
      run
    end

    def host(h)
      @options.host = h
    end

    def port(p)
      @options.port = p
    end

    def logger(l)
      puts "assign a logger"
      puts l.inspect
      @options.logger = l
    end

    def access_key(key)
      @options.access_key = key
    end

    def secret_key(key)
      @options.secret_key = key
    end

    def domain(key)
      @options.domain = key
    end

    def before_send(&block)
      @options.before_send = block
    end

    def after_send(&block)
      @options.after_send = block
    end

private

    def run
      self.instance_eval(File.read(@path), @path, 0)
    rescue => e
      raise Error.new("#{e.message} at #{e.backtrace[0].gsub(/:in `run'/,'')}")
    end

  end
end
