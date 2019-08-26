module StrongPassword
  class QwertyAdjuster
    QWERTY_STRINGS = [
      '1234567890-',
      'qwertyuiop',
      'asdfghjkl;',
      'zxcvbnm,./',
      "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik,9ol.0p;/-['=]:?_{\"+}",
      '1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p',
      "qazwsxedcrfvtgbyhnujmik,ol.p;/-['=]:?_{\"+}",
      'qazwsxedcrfvtgbyhnujmikolp',
      ']"/=[;.-pl,0okm9ijn8uhb7ygv6tfc5rdx4esz3wa2q1',
      'pl0okm9ijn8uhb7ygv6tfc5rdx4esz3wa2q1',
      ']"/[;.pl,okmijnuhbygvtfcrdxeszwaq',
      'plokmijnuhbygvtfcrdxeszwaq',
      '014725836914702583697894561230258/369*+-*/',
      'abcdefghijklmnopqrstuvwxyz'
    ].freeze

    attr_reader :min_entropy, :entropy_threshhold

    def initialize(min_entropy: 18, entropy_threshhold: min_entropy)
      @min_entropy = min_entropy
      @entropy_threshhold = entropy_threshhold
    end

    def is_strong?(base_password)
      adjusted_entropy(base_password) >= min_entropy
    end

    def is_weak?(base_password)
      !is_strong?(base_password)
    end

    # Returns the minimum entropy for the password's qwerty locality
    # adjustments.  If a threshhold is specified we will bail
    # early to avoid unnecessary processing.
    def adjusted_entropy(base_password)
      revpassword = base_password.reverse
      lowest_entropy = [EntropyCalculator.calculate(base_password), EntropyCalculator.calculate(revpassword)].min
      # If our entropy is already lower than we care about then there's no reason to look further.
      return lowest_entropy if lowest_entropy < entropy_threshhold

      qpassword = mask_qwerty_strings(base_password)
      lowest_entropy = [lowest_entropy, EntropyCalculator.calculate(qpassword)].min if qpassword != base_password
      # Bail early if our entropy on the base password's masked qwerty value is less than our threshold.
      return lowest_entropy if lowest_entropy < entropy_threshhold

      qrevpassword = mask_qwerty_strings(revpassword)
      lowest_entropy = [lowest_entropy, EntropyCalculator.calculate(qrevpassword)].min if qrevpassword != revpassword
      lowest_entropy
    end

    private

    def all_qwerty_strings
      @all_qwerty_strings ||= Regexp.union(QWERTY_STRINGS.flat_map do |qwerty_string|
        gen_qw_strings(qwerty_string)
      end)
    end

    def gen_qw_strings(qwerty_string)
      6.downto(3).flat_map do |z|
        y = qwerty_string.length - z
        (0..y).map do |x|
          qwerty_string[x, z].sub('-', '\\-')
        end
      end
    end

    def mask_qwerty_strings(password)
      password.gsub(all_qwerty_strings, '*')
    end
  end
end
