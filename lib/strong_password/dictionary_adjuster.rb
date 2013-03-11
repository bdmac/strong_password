module StrongPassword
  class DictionaryAdjuster
    COMMON_PASSWORDS = ["123456","password","12345678","1234","pussy","12345","dragon","qwerty",
      "696969","mustang","letmein","baseball","master","michael","football","shadow","monkey","abc123",
      "pass","6969","jordan","harley","ranger","iwantu","jennifer","hunter","2000","test","batman",
      "trustno1","thomas","tigger","robert","access","love","buster","1234567","soccer","hockey","killer",
      "george","sexy","andrew","charlie","superman","asshole","dallas","jessica","panties","pepper",
      "1111","austin","william","daniel","golfer","summer","heather","hammer","yankees","joshua","maggie",
      "biteme","enter","ashley","thunder","cowboy","silver","richard","orange","merlin","michelle",
      "corvette","bigdog","cheese","matthew","121212","patrick","martin","freedom","ginger","blowjob",
      "nicole","sparky","yellow","camaro","secret","dick","falcon","taylor","111111","131313","123123",
      "bitch","hello","scooter","please","","porsche","guitar","chelsea","black","diamond","nascar",
      "jackson","cameron","654321","computer","amanda","wizard","xxxxxxxx","money","phoenix","mickey",
      "bailey","knight","iceman","tigers","purple","andrea","horny","dakota","aaaaaa","player","sunshine",
      "morgan","starwars","boomer","cowboys","edward","charles","girls","booboo","coffee","xxxxxx",
      "bulldog","ncc1701","rabbit","peanut","john","johnny","gandalf","spanky","winter","brandy","compaq",
      "carlos","tennis","james","mike","brandon","fender","anthony","blowme","ferrari","cookie","chicken",
      "maverick","chicago","joseph","diablo","sexsex","hardcore","666666","willie","welcome","chris",
      "panther","yamaha","justin","banana","driver","marine","angels","fishing","david","maddog","hooters",
      "wilson","butthead","dennis","captain","bigdick","chester","smokey","xavier","steven","viking",
      "snoopy","blue","eagles","winner","samantha","house","miller","flower","jack","firebird","butter",
      "united","turtle","steelers","tiffany","zxcvbn","tomcat","golf","bond007","bear","tiger","doctor",
      "gateway","gators","angel","junior","thx1138","porno","badboy","debbie","spider","melissa","booger",
      "1212","flyers","fish","porn","matrix","teens","scooby","jason","walter","cumshot","boston","braves",
      "yankee","lover","barney","victor","tucker","princess","mercedes","5150","doggie","zzzzzz","gunner",
      "horney","bubba","2112","fred","johnson","xxxxx","tits","member","boobs","donald","bigdaddy","bronco",
      "penis","voyager","rangers","birdie","trouble","white","topgun","bigtits","bitches","green","super",
      "qazwsx","magic","lakers","rachel","slayer","scott","2222","asdf","video","london","7777","marlboro",
      "srinivas","internet","action","carter","jasper","monster","teresa","jeremy","11111111","bill","crystal",
      "peter","pussies","cock","beer","rocket","theman","oliver","prince","beach","amateur","7777777","muffin",
      "redsox","star","testing","shannon","murphy","frank","hannah","dave","eagle1","11111","mother","nathan",
      "raiders","steve","forever","angela","viper","ou812","jake","lovers","suckit","gregory","buddy",
      "whatever","young","nicholas","lucky","helpme","jackie","monica","midnight","college","baby","brian",
      "mark","startrek","sierra","leather","232323","4444","beavis","bigcock","happy","sophie","ladies",
      "naughty","giants","booty","blonde","golden","0","fire","sandra","pookie","packers","einstein",
      "dolphins","0","chevy","winston","warrior","sammy","slut","8675309","zxcvbnm","nipples","power",
      "victoria","asdfgh","vagina","toyota","travis","hotdog","paris","rock","xxxx","extreme","redskins",
      "erotic","dirty","ford","freddy","arsenal","access14","wolf","nipple","iloveyou","alex","florida",
      "eric","legend","movie","success","rosebud","jaguar","great","cool","cooper","1313","scorpio",
      "mountain","madison","987654","brazil","lauren","japan","naked","squirt","stars","apple","alexis",
      "aaaa","bonnie","peaches","jasmine","kevin","matt","qwertyui","danielle","beaver","4321","4128",
      "runner","swimming","dolphin","gordon","casper","stupid","shit","saturn","gemini","apples","august",
      "3333","canada","blazer","cumming","hunting","kitty","rainbow","112233","arthur","cream","calvin",
      "shaved","surfer","samson","kelly","paul","mine","king","racing","5555","eagle","hentai","newyork",
      "little","redwings","smith","sticky","cocacola","animal","broncos","private","skippy","marvin",
      "blondes","enjoy","girl","apollo","parker","qwert","time","sydney","women","voodoo","magnum",
      "juice","abgrtyu","777777","dreams","maxwell","music","rush2112","russia","scorpion","rebecca",
      "tester","mistress","phantom","billy","6666","albert"]
    
    attr_reader :base_password
    
    def initialize(password)
      @base_password = password.dup.downcase
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
      dictionary_words = COMMON_PASSWORDS + extra_dictionary_words
      min_entropy = EntropyCalculator.calculate(base_password)
      # Process the passwords, while looking for possible matching words in the dictionary.
      PasswordVariants.all_variants(base_password).each_with_index do |variant, num|
        y = variant.length
        x = -1
        while x < y
          x = x + 1
          if ((variant[x] =~ /\w/) != nil)
            next_non_word = variant.index(/\s/, x)
            x2 =  next_non_word ? next_non_word : variant.length + 1
            found = false
            while !found && (x2 - x >= min_word_length)
              word = variant[x, min_word_length]
              word += variant[(x + min_word_length)..x2].reverse.chars.inject('') {|memo, c| "(#{Regexp.quote(c)}#{memo})?"} if (x + min_word_length) <= y
              results = dictionary_words.grep(/\b#{word}\b/)
              if results.empty?
                x = x + 1
                numbits = EntropyCalculator.calculate('*' * x)
                # If we have enough entropy at this length on a fully masked password with 
                # duplicates weakened then we can just bail on this variant
                found = true if entropy_threshhold >= 0 && numbits >= entropy_threshhold
              else
                results.each do |match|
                  break unless match.present?
                  # Substitute a single * for matched portion of word and calculate entropy
                  variant = variant.sub(match.strip.sub('-', '\\-'), '*')
                  numbits = EntropyCalculator.calculate(variant)
                  min_entropy = [min_entropy, numbits].min
                  return min_entropy if min_entropy < entropy_threshhold
                end

                found = true
              end
            end

            break if found

            x = x2 - 1
          end
        end
      end
      return min_entropy
    end
  end
end