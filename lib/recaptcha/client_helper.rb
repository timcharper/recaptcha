module Recaptcha
  module ClientHelper
    # Your public API can be specified in the +options+ hash or preferably
    # the environment variable +RECAPTCHA_PUBLIC_KEY+.
    def recaptcha_tags(options = {})
      # Default options
      key   = options[:public_key] ||= ENV['RECAPTCHA_PUBLIC_KEY']
      raise RecaptchaError, "No public key specified." unless key
      error = options[:error] ||= recaptcha_error
      uri   = options[:ssl] ? RECAPTCHA_API_SECURE_SERVER : RECAPTCHA_API_SERVER
      html  = ""
      if options[:display]
        html << <<-EOF
          <script type="text/javascript">
            var RecaptchaOptions = #{options[:display].to_json};
          </script>
        EOF
      end
      if options[:ajax]
        html << <<-EOF
          <div id="dynamic_recaptcha"></div>
          <script type="text/javascript" src="#{uri}/js/recaptcha_ajax.js"></script>
          <script type="text/javascript">
            Recaptcha.create('#{key}', document.getElementById('dynamic_recaptcha')#{options[:display] ? ',RecaptchaOptions' : ''});
          </script>
        EOF
      else
        html << %{<script type="text/javascript" src="#{uri}/challenge?k=#{key}}
        html << %{#{error ? "&error=#{CGI::escape(error)}" : ""}"></script>\n}
        unless options[:noscript] == false
          html << <<-EOF
            <noscript>
            <iframe src="#{uri}/noscript?k=#{key}"
              height="#{options[:iframe_height] ||= 300}"
              width="#{options[:iframe_width]   ||= 500}"
              frameborder="0"></iframe><br/>
            <textarea name="recaptcha_challenge_field"
              rows="#{options[:textarea_rows] ||= 3}"
              cols="#{options[:textarea_cols] ||= 40}"></textarea>
            <input type="hidden" name="recaptcha_response_field" value="manual_challenge"
            </noscript>
          EOF
        end
      end
      html.respond_to?(:html_safe) ? html.html_safe : html
    end

    def recaptcha_error_message
      Recaptcha::ERROR_MESSAGES[recaptcha_error] if recaptcha_error
    end
  end
end
