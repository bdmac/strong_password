module StrongPassword
  class StrengthChecker
    BASE_ENTROPY = 18
    PASSWORD_LIMIT = 1_000
    EXTRA_WORDS_LIMIT = 50_000

    attr_reader :base_password

    def initialize(password)
      @base_password = password.dup[0...PASSWORD_LIMIT]
    end

    def is_weak?(min_entropy: BASE_ENTROPY, use_dictionary: false, min_word_length: 4, extra_dictionary_words: [])
      !is_strong?(min_entropy: min_entropy,
                  use_dictionary: use_dictionary, 
                  min_word_length: min_word_length, 
                  extra_dictionary_words: extra_dictionary_words)
    end

    def is_strong?(min_entropy: BASE_ENTROPY, use_dictionary: false, min_word_length: 4, extra_dictionary_words: [])
      weak = (EntropyCalculator.calculate(base_password) < min_entropy) ||
             (EntropyCalculator.calculate(base_password.downcase) < min_entropy) ||
             (QwertyAdjuster.new(base_password).is_weak?(min_entropy: min_entropy))
      if !weak && use_dictionary
        return DictionaryAdjuster.new(base_password).is_strong?(min_entropy: min_entropy,
                    min_word_length: min_word_length, 
                    extra_dictionary_words: extra_dictionary_words)
      else
        return !weak
      end
    end

    def calculate_entropy(use_dictionary: false, min_word_length: 4, extra_dictionary_words: [])
      extra_dictionary_words.collect! { |w| w[0...EXTRA_WORDS_LIMIT] }
      entropies = [EntropyCalculator.calculate(base_password), EntropyCalculator.calculate(base_password.downcase), QwertyAdjuster.new(base_password).adjusted_entropy]
      entropies << DictionaryAdjuster.new(base_password).adjusted_entropy(min_word_length: min_word_length, extra_dictionary_words: extra_dictionary_words) if use_dictionary
      entropies.min
    end
  end
end
