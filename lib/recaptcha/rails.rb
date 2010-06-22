require 'recaptcha'

# Usage:
#   require "recaptcha/rails".  It will define an attribute
module Recaptcha::RailsErrorAccessors
  def self.included(klass)
    klass.cattr_accessor(:redirect_after_captcha_fail)
    helper_method :recaptcha_error
  end

  def recaptcha_error=(error_code)
    (self.class.redirect_after_captcha_fail ? flash : flash.now)[:recaptcha_error] = error_code
  end

  def recaptcha_error
    (self.class.redirect_after_captcha_fail ? flash : flash.now)[:recaptcha_error]
  end
end

ActionView::Base.send(:include, Recaptcha::ClientHelper)
ActionController::Base.send(:include, Recaptcha::RailsErrorAccessors)
ActionController::Base.send(:include, Recaptcha::Verify)