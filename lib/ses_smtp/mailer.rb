require 'time'
require 'base64'
require 'mail'
require 'cgi'
require 'em-http-request'

module SesSmtp
  #
  # interface with SES
  #
  # used: https://github.com/drewblas/aws-ses/blob/master/lib/aws/ses/base.rb as reference
  #
  class Mailer

    class << self
      # Encodes the given string with the secret_access_key by taking the
      # hmac-sha1 sum, and then base64 encoding it.  Optionally, it will also
      # url encode the result of that to protect the string if it's going to
      # be used as a query string parameter.
      #
      # @param [String] secret_access_key the user's secret access key for signing.
      # @param [String] str the string to be hashed and encoded.
      # @param [Boolean] urlencode whether or not to url encode the result., true or false
      # @return [String] the signed and encoded string.
      def encode(secret_access_key, str, urlencode=true)
        digest = OpenSSL::Digest::Digest.new('sha256')
        b64_hmac =
          Base64.encode64(
            OpenSSL::HMAC.digest(digest, secret_access_key, str)).gsub("\n","")

        if urlencode
          return CGI::escape(b64_hmac)
        else
          return b64_hmac
        end
      end

      # Generates the HTTP Header String that Amazon looks for
      # 
      # @param [String] key the AWS Access Key ID
      # @param [String] alg the algorithm used for the signature
      # @param [String] sig the signature itself
      def authorization_header(key, alg, sig)
        "AWS3-HTTPS AWSAccessKeyId=#{key}, Algorithm=#{alg}, Signature=#{sig}"
      end

    end

    def initialize(config)
      @config = config
    end

    def send_email_raw(message)
      timestamp = Time.now.getutc

      params = {"Action" => "SendRawEmail",
                "SignatureVersion" => "2",
                "SignatureMethod" => 'HmacSHA256',
                "AWSAccessKeyId" => @config.options.access_key,
                "Version" => @config.options.api,
                "Timestamp" => timestamp.iso8601,
                # TODO: error handling
                'RawMessage.Data' => Base64::encode64(Mail.new(message.to_hash).to_s) }

      query = params.sort.map do |param|
        CGI::escape(param[0]) + "=" + CGI::escape(param[1])
      end.join("&")

      req = {}

      req['X-Amzn-Authorization'] = get_aws_auth_param(timestamp)
      req['Date'] = timestamp.httpdate
      req['User-Agent'] = "captico-ses-smtp"

      EM::HttpRequest.new("https://" + @config.options.server + "/").post :body => query, :head => req

    end

    # Set the Authorization header using AWS signed header authentication
    def get_aws_auth_param(timestamp)
      encoded_canonical = Mailer.encode(@config.options.secret_key, timestamp.httpdate, false)
      Mailer.authorization_header(@config.options.access_key, 'HmacSHA256', encoded_canonical)
    end

  end
end
