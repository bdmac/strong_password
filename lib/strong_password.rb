require 'active_model/validations' if defined?(ActiveModel)

require 'strong_password/version'
require 'strong_password/nist_bonus_bits'
require 'strong_password/entropy_calculator'
require 'strong_password/strength_checker'
require 'strong_password/password_variants'
require 'strong_password/dictionary_adjuster'
require 'strong_password/qwerty_adjuster'
require 'active_model/validations/password_strength_validator' if defined?(ActiveModel)

module StrongPassword
end

I18n.load_path << File.dirname(__FILE__) + '/strong_password/locale/en.yml' if defined?(I18n)
