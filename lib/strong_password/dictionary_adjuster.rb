module StrongPassword   
  class DictionaryAdjuster
    def self.common_passwords_string
      @common_passwords_string ||= File.open(File.expand_path("../dictionary_adjuster.txt", __FILE__), 'rb') { |file| file.read }
    end

    def self.common_passwords
      common_passwords_string.split(' ')
    end

    attr_reader :base_password

    def initialize(password)
      @base_password = password.downcase
    end

    def is_strong?(min_entropy: 18, min_word_length: 4, extra_dictionary_words: [])
      adjusted_entropy(entropy_threshhold: min_entropy,
                       min_word_length: min_word_length,
                       extra_dictionary_words: extra_dictionary_words) >= min_entropy
    end

    def is_weak?(min_entropy: 18, min_word_length: 4, extra_dictionary_words: [])
      !is_strong?(min_entropy: min_entropy, min_word_length: min_word_length, extra_dictionary_words: extra_dictionary_words)
    end

    # Returns the minimum entropy for the passwords dictionary adjustments.
    # If a threshhold is specified we will bail early to avoid unnecessary
    # processing.
    # Note that we only check for the first matching word up to the threshhold if set.
    # Subsequent matching words are not deductd.
    def adjusted_entropy(min_word_length: 4, extra_dictionary_words: [], entropy_threshhold: -1)
      dictionary_words = Regexp.union( ( extra_dictionary_words + self.class.common_passwords ).compact.reject{ |i| i.length < min_word_length } )
      min_entropy = EntropyCalculator.calculate(base_password)
      # Process the passwords, while looking for possible matching words in the dictionary.
      PasswordVariants.all_variants(base_password).inject( min_entropy ) do |min_entropy, variant|
        [ min_entropy, EntropyCalculator.calculate( variant.sub( dictionary_words, '*' ) ) ].min 
      end
    end
  end
end