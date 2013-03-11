module StrongPassword
  module Validators
    class PasswordStrengthValidator < ActiveModel::EachValidator
      def validate_each(object, attribute, value)
        ps = ::StrongPassword::StrengthChecker.new(value)
        unless ps.is_strong?(strength_options(options, object))
          object.errors.add(attribute, :password_strength, options.merge(:value => value))
        end
      end

      def strength_options(options, object)
        strength_options = options.dup
        strength_options[:extra_dictionary_words] = extra_words_for_object(strength_options[:extra_dictionary_words], object)
        strength_options
      end

      def extra_words_for_object(extra_words, object)
        return [] unless extra_words.present?
        if object
          if extra_words.respond_to?(:call)
            extra_words = extra_words.call(object)
          elsif extra_words.kind_of? Symbol
            extra_words = object.send(extra_words)
          end
        end
        extra_words || []
      end
    end
  end
end

# Refactor this to... railtie?
module ::ActiveModel::Validations::HelperMethods
  def validates_password_strength(*attr_names)
    validates_with ::StrongPassword::Valiators::PasswordStrengthValidator, _merge_attributes(attr_names)
  end
end