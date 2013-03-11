require 'active_model/validations'

require 'strong_password/version'
require 'strong_password/nist_bonus_bits'
require 'strong_password/entropy_calculator'
require 'strong_password/strength_checker'
require 'strong_password/password_variants'
require 'strong_password/dictionary_adjuster'
require 'strong_password/qwerty_adjuster'
require 'strong_password/validators/strength_validator' if defined?(ActiveModel)
require 'strong_password/railtie' if defined?(Rails)

module StrongPassword
end