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
      min_entropy = [EntropyCalculator.calculate(base_password), EntropyCalculator.calculate(revpassword)].min
      qpassword = mask_qwerty_strings(base_password)
      qrevpassword = mask_qwerty_strings(revpassword)
      if qpassword != base_password
        numbits = EntropyCalculator.calculate(qpassword)
        min_entropy = [min_entropy, numbits].min
        return min_entropy if min_entropy < entropy_threshhold
      end
      if qrevpassword != revpassword
        numbits = EntropyCalculator.calculate(qrevpassword)
        min_entropy = [min_entropy, numbits].min
        return min_entropy if min_entropy < entropy_threshhold
      end
      min_entropy
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
