require 'recaptcha/client_helper'
require 'recaptcha/verify'

module Recaptcha
  module VERSION #:nodoc:
    MAJOR = 0
    MINOR = 2
    TINY  = 2
    PATCH = 1

    STRING = [MAJOR, MINOR, TINY, PATCH].join('.')
  end

  RECAPTCHA_API_SERVER        = 'http://api.recaptcha.net';
  RECAPTCHA_API_SECURE_SERVER = 'https://api-secure.recaptcha.net';
  RECAPTCHA_VERIFY_SERVER     = 'api-verify.recaptcha.net';

  TIMEOUT_ERROR = "recaptcha-not-reachable"
  ERROR_MESSAGES = {
    "unknown"                  => "an unknown error occurred",
    "invalid-site-public-key"  => "ReCaptcha couldn't verify the public key. This is an issue with this site.",
    "invalid-site-private-key" => "ReCaptcha couldn't verify the private key. This is an issue with this site.",
    "invalid-request-cookie"   => "The challenge parameter of the verify script was incorrect.",
    "incorrect-captcha-sol"    => "Word verification response is incorrect, please try again.",
    "verify-params-incorrect"  => "The parameters to /verify were incorrect, make sure you are passing all the required parameters.",
    "invalid-referrer"         => "Invalid Referer",
    TIMEOUT_ERROR              => "Oops, we failed to validate your word verification response. Please try again."
  }
  SKIP_VERIFY_ENV = ['test', 'cucumber']

  class RecaptchaError < StandardError
  end
end