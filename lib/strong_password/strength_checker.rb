module StrongPassword
  class StrengthChecker
    BASE_ENTROPY = 18
    PASSWORD_LIMIT = 1_000
    EXTRA_WORDS_LIMIT = 1_000

    attr_reader :min_entropy, :use_dictionary, :min_word_length, :extra_dictionary_words

    def initialize(min_entropy: BASE_ENTROPY, use_dictionary: false, min_word_length: 4, extra_dictionary_words: [])
      @min_entropy = min_entropy
      @use_dictionary = use_dictionary
      @min_word_length = min_word_length
      @extra_dictionary_words = extra_dictionary_words
    end

    def is_weak?(password)
      !is_strong?(password)
    end

    def is_strong?(password)
      base_password = password.dup[0...PASSWORD_LIMIT]
      weak = (EntropyCalculator.calculate(base_password) < min_entropy) ||
             (EntropyCalculator.calculate(base_password.downcase) < min_entropy) ||
             (QwertyAdjuster.new(min_entropy: min_entropy).is_weak?(base_password))
      if !weak && use_dictionary
        return DictionaryAdjuster.new(
          min_entropy: min_entropy,
          min_word_length: min_word_length,
          extra_dictionary_words: extra_dictionary_words
        ).is_strong?(base_password)
      else
        return !weak
      end
    end

    def calculate_entropy(password)
      base_password = password.dup[0...PASSWORD_LIMIT]
      extra_dictionary_words.collect! { |w| w[0...EXTRA_WORDS_LIMIT] }
      entropies = [EntropyCalculator.calculate(base_password), EntropyCalculator.calculate(base_password.downcase), QwertyAdjuster.new.adjusted_entropy(base_password)]
      entropies << DictionaryAdjuster.new(
        min_word_length: min_word_length,
        extra_dictionary_words: extra_dictionary_words
      ).adjusted_entropy(base_password) if use_dictionary
      entropies.min
    end
  end
end
