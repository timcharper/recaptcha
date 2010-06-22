require 'recaptcha'

# completely untested... suggested to adjust to match behavior of rails
module Recaptcha::MerbErrorAccessors
  attr_accessor :recaptcha_error
end

Merb::GlobalHelpers.send(:include, Recaptcha::ClientHelper)
Merb::Controller.send(:include, Recaptcha::MerbErrorAccessors)
Merb::Controller.send(:include, Recaptcha::Verify)
