module Recaptcha
  module Verify
    RECAPTCHA_TIMEOUT_ERROR = "recaptcha-not-reachable"
    RECAPTCHA_TIMEOUT_MESSAGE = "Oops, we failed to validate your word verification response. Please try again."
    RECAPTCHA_VALIDATION_FAILED_MESSAGE = "Word verification response is incorrect, please try again."

    def send_recaptcha_verification_request(remote_ip, challenge, response, private_key = nil, timeout = 3)
      private_key ||= ENV['RECAPTCHA_PRIVATE_KEY']
      raise RecaptchaError, "No private key specified." unless private_key
      
      begin
        recaptcha = nil
        Timeout::timeout(timeout || 3) do
          recaptcha = Net::HTTP.post_form(
            URI.parse("http://#{RECAPTCHA_VERIFY_SERVER}/verify"), {
              "privatekey" => private_key,
              "remoteip"   => remote_ip,
              "challenge"  => challenge,
              "response"   => response})
        end
        answer, error = recaptcha.body.split.map { |s| s.chomp }
        if answer == 'true'
          [true, nil]
        else
          [false, error]
        end
      rescue Timeout::Error 
        [false, RECAPTCHA_TIMEOUT_ERROR]
      rescue Exception => e
        raise RecaptchaError, e.message, e.backtrace
      end
    end

    # Your private API can be specified in the +options+ hash or preferably
    # the environment variable +RECAPTCHA_PUBLIC_KEY+.
    def verify_recaptcha(options = {})
      env = options[:env] || ENV['RAILS_ENV']
      return true if SKIP_VERIFY_ENV.include? env

      if !options.is_a? Hash
        STDERR.puts "DEPRECATION WARNING: verify_recaptcha expects a hash"
        options = {:model => options}
      end

      success, self.recaptcha_error = send_recaptcha_verification_request(
        request.remote_ip,
        params[:recaptcha_challenge_field],
        params[:recaptcha_response_field],
        options[:private_key],
        options[:timeout] || 3)

      if ! success && options[:model]
        add_recaptcha_model_errors(options[:model],
                                   options[:attribute],
                                   :timeout_message => options[:timeout_message] || options[:message], # TODO: deprecate options[:message], not specific enough.
                                   :validation_failed_message => options[:validation_failed_message] || options[:message])
      end
      success
    end

    # I'm inclined to believe this is a bad idea: it causes many problem for model validation domain to be considered here. Including for backwards compatibility
    def add_recaptcha_model_errors(model, attribute, options = {})
      attribute ||= :base
      model.valid? # invoke validation
      if recaptcha_error == RECAPTCHA_TIMEOUT_ERROR
        model.errors.add attribute, options[:timeout_message] || RECAPTCHA_TIMEOUT_MESSAGE
      else
        model.errors.add attribute, options[:validation_failed_message] || RECAPTCHA_VALIDATION_FAILED_MESSAGE
      end
    end
  end # Verify
end # Recaptcha
