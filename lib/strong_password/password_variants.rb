module StrongPassword
  module PasswordVariants
    LEET_SPEAK_REGEXP = /[\@\!\$1234567890]/

    LEET_SPEAK = {
      "@" => "a",
      "!" => "i",
      "$" => "s",
      "1" => "i",
      "2" => "z",
      "3" => "e",
      "4" => "a",
      "5" => "s",
      "6" => "g",
      "7" => "t",
      "8" => "b",
      "9" => "g",
      "0" => "o"
    }

    LEET_SPEAK_ALT = LEET_SPEAK.dup.merge!("1" => "l")

    BOTTOM_ROW_REGEXP = /[zxcvbnm,\.\/\<\>\?]/

    KEYBOARDMAP_DOWNRIGHT = {
      "a" => "z",
      "q" => "a",
      "1" => "q",
      "s" => "x",
      "w" => "s",
      "2" => "w",
      "d" => "c",
      "e" => "d",
      "3" => "e",
      "f" => "v",
      "r" => "f",
      "4" => "r",
      "g" => "b",
      "t" => "g",
      "5" => "t",
      "h" => "n",
      "y" => "h",
      "6" => "y",
      "j" => "m",
      "u" => "j",
      "7" => "u",
      "i" => "k",
      "8" => "i",
      "o" => "l",
      "9" => "o",
      "0" => "p"
    }

    KEYBOARDMAP_DOWNLEFT = {
      "2" => "q",
      "w" => "a",
      "3" => "w",
      "s" => "z",
      "e" => "s",
      "4" => "e",
      "d" => "x",
      "r" => "d",
      "5" => "r",
      "f" => "c",
      "t" => "f",
      "6" => "t",
      "g" => "v",
      "y" => "g",
      "7" => "y",
      "h" => "b",
      "u" => "h",
      "8" => "u",
      "j" => "n",
      "i" => "j",
      "9" => "i",
      "k" => "m",
      "o" => "k",
      "0" => "o",
      "p" => "l",
      "-" => "p"
    }

    # Returns all variants of a given password including the password itself
    def self.all_variants(password)
      passwords = [password.downcase]
      passwords += keyboard_shift_variants(password)
      passwords += leet_speak_variants(password)
      passwords.uniq
    end

    # Returns all keyboard shifted variants of a given password
    def self.keyboard_shift_variants(password)
      password = password.downcase

      return [] if password.match(BOTTOM_ROW_REGEXP)
      variants(password, KEYBOARDMAP_DOWNRIGHT, KEYBOARDMAP_DOWNLEFT)
    end

    # Returns all leet speak variants of a given password
    def self.leet_speak_variants(password)
      password = password.downcase

      return [] if !password.match(LEET_SPEAK_REGEXP)
      variants(password, LEET_SPEAK, LEET_SPEAK_ALT)
    end

    private

    def self.variants(password, *mappings)
      mappings.flat_map do |map|
        variant = password.tr(map.keys.join, map.values.join)
        [variant, variant.reverse]
      end
    end
  end
end
