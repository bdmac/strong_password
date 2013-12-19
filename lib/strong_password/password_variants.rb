module StrongPassword
  module PasswordVariants
    LEET_SPEAK_1 = {
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

    LEET_SPEAK_2 = {
      "@" => "a",
      "!" => "i",
      "$" => "s",
      "1" => "l",
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

    KEYBOARDMAP_DOWN_NOSHIFT = {
      "z" => "", 
      "x" => "", 
      "c" => "", 
      "v" => "", 
      "b" => "", 
      "n" => "", 
      "m" => "", 
      "," => "", 
      "." => "", 
      "/" => "", 
      "<" => "", 
      ">" => "", 
      "?" => ""
    }

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
      variants = []
      
      if (password == password.tr(KEYBOARDMAP_DOWN_NOSHIFT.keys.join, KEYBOARDMAP_DOWN_NOSHIFT.values.join))
        variant = password.tr(KEYBOARDMAP_DOWNRIGHT.keys.join, KEYBOARDMAP_DOWNRIGHT.values.join)
        variants << variant
        variants << variant.reverse

        variant = password.tr(KEYBOARDMAP_DOWNLEFT.keys.join, KEYBOARDMAP_DOWNLEFT.values.join)
        variants << variant
        variants << variant.reverse
      end
      variants
    end

    # Returns all leet speak variants of a given password
    def self.leet_speak_variants(password)
      password = password.downcase
      variants = []

      leet = password.tr(LEET_SPEAK_1.keys.join, LEET_SPEAK_1.values.join)
      if leet != password
        variants << leet
        variants << leet.reverse
      end

      leet_l = password.tr(LEET_SPEAK_2.keys.join, LEET_SPEAK_2.values.join)
      if (leet_l != password && leet_l != leet)
        variants << leet_l
        variants << leet_l.reverse
      end
      variants
    end
  end
end