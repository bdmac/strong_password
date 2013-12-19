module StrongPassword
  class QwertyAdjuster
    QWERTY_STRINGS = [
      "1234567890-",
      "qwertyuiop",
      "asdfghjkl;",
      "zxcvbnm,./",
      "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik,9ol.0p;/-['=]:?_{\"+}",
      "1qaz2wsx3edc4rfv5tgb6yhn7ujm8ik9ol0p",
      "qazwsxedcrfvtgbyhnujmik,ol.p;/-['=]:?_{\"+}",
      "qazwsxedcrfvtgbyhnujmikolp",
      "]\"/=[;.-pl,0okm9ijn8uhb7ygv6tfc5rdx4esz3wa2q1",
      "pl0okm9ijn8uhb7ygv6tfc5rdx4esz3wa2q1",
      "]\"/[;.pl,okmijnuhbygvtfcrdxeszwaq",
      "plokmijnuhbygvtfcrdxeszwaq",
      "014725836914702583697894561230258/369*+-*/",
      "abcdefghijklmnopqrstuvwxyz"
    ]
    
    attr_reader :base_password
    
    def initialize(password)
      @base_password = password.downcase
    end
    
    def is_strong?(min_entropy: 18)
      adjusted_entropy(entropy_threshhold: min_entropy) >= min_entropy
    end
    
    def is_weak?(min_entropy: 18)
      !is_strong?(min_entropy: min_entropy)
    end
    
    # Returns the minimum entropy for the password's qwerty locality
    # adjustments.  If a threshhold is specified we will bail
    # early to avoid unnecessary processing.
    def adjusted_entropy(entropy_threshhold: 0)
      revpassword = base_password.reverse
      min_entropy = [EntropyCalculator.calculate(base_password), EntropyCalculator.calculate(revpassword)].min
      QWERTY_STRINGS.each do |qwertystr|
        qpassword = mask_qwerty_strings(base_password, qwertystr)
        qrevpassword = mask_qwerty_strings(revpassword, qwertystr)
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
      end
      min_entropy
    end
  
  private
  
    def mask_qwerty_strings(password, qwerty_string)
      masked_password = password
      z = 6
      begin
        y = qwerty_string.length - z
        (0..y).each do |x|
          str = qwerty_string[x, z].sub('-', '\\-')
          masked_password = masked_password.sub(str, '*')
        end
        z = z - 1
      end while z > 2
      masked_password
    end
  end
end