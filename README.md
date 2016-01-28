[![Build Status](https://travis-ci.org/bdmac/strong_password.svg?branch=master)](https://travis-ci.org/bdmac/strong_password)
[![Code Climate](https://codeclimate.com/github/bdmac/strong_password/badges/gpa.svg)](https://codeclimate.com/github/bdmac/strong_password)
[![Test Coverage](https://codeclimate.com/github/bdmac/strong_password/badges/coverage.svg)](https://codeclimate.com/github/bdmac/strong_password/coverage)

# StrongPassword

StrongPassword provides entropy-based password strength checking for your apps.

The idea stemmed from the
"[Checking Password Strength](http://stackoverflow.com/questions/549/the-definitive-guide-to-forms-based-website-authentication)"
section on StackOverflow.

It is an adaptation of a [PHP algorithm](http://cubicspot.blogspot.com/2011/11/how-to-calculate-password-strength.html)
developed by Thomas Hruska.

## Installation

NOTE: StrongPassword requires the use of Ruby 2.0.  Upgrade if you haven't already!

Add this line to your application's Gemfile:

    gem 'strong_password', '~> 0.0.5'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install strong_password

## Usage

StrongPassword is designed primarily to be used with Rails and ActiveModel validations but can also be
used standalone if needed.

### With Rails/ActiveModel Validations

StrongPassword adds a custom validator for use with ActiveModel validations.  Your model does NOT need to be an ActiveRecord
model, it simply has to be an object that includes `ActiveModel::Validations`.  Use it like so:

```ruby
class User
  include ActiveModel::Validations

  # Basic usage.  Defaults to minimum entropy of 18 and no dictionary checking
  validates :password, password_strength: true
  # Minimum entropy can be specified as min_entropy
  validates :password, password_strength: {min_entropy: 40}
  # Specifies that we want to use dictionary checking
  validates :password, password_strength: {use_dictionary: true}
  # Specifies the minimum size of things that should count as words.  Defaults to 4.
  validates :password, password_strength: {use_dictionary: true, min_word_length: 6}
  # Specifies that we want to use dictionary checking and adds 'other', 'common', and 'words' to the dictionary we are checking against.
  validates :password, password_strength: {extra_dictionary_words: ['other', 'common', 'words'], use_dictionary: true}
  # You can also specify a method name to pull the extra words from
  validates :password, password_strength: {extra_dictionary_words: :my_extra_words, use_dictionary: true}
  # Alternative way to request password strength validation on a field
  validates_password_strength :password

  # Return an array of words to add to the dictionary we check against.
  def my_extra_words
    ['extra', 'words', 'here', 'too']
  end
end
```

The default validation message is "is too weak". Rails will display a field of `:password` having too weak of a password with `full_error_messages` as "Password is too weak". If you would like to customize the error message, you can override it in your locale file by setting a value for this key:


```yml
en:
  errors:
    messages:
      password:
        password_strength: "is a terrible password, try again!"
```

### Standalone

StrongPassword can also be used standalone if you need to. There are a few helper methods for determining whether a
password is strong or not. You can also directly access the entropy calculations if you want.

```text
2.0.0p0 :001 > checker = StrongPassword::StrengthChecker.new('password')
 => #<StrongPassword::StrengthChecker:0x007fcd7c939b48 @base_password="password">
2.0.0p0 :002 > checker.is_strong?
 => false
2.0.0p0 :003 > checker.is_weak?
 => true
2.0.0p0 :004 > checker.is_strong?(min_entropy: 2)
 => true
2.0.0p0 :005 > checker.calculate_entropy
 => 15.5
2.0.0p0 :006 > checker.calculate_entropy(use_dictionary: true)
 => 2
```

## Details

So what exactly does StrongPassword do for you? If you're really interested you should [read this article](http://cubicspot.blogspot.com/2011/11/how-to-calculate-password-strength.html)
from the original author of the algorithm.

For the most part StrongPassword stays true to the original but is refactored and tested.  I will try to summarize what
the algorithm does here but reading the code is probably the best way to really get a feel for it.

The basic premise is to use the NIST suggested rules for entropy calculation as follows:

* The first byte counts as 4 bits.
* The next 7 bytes count as 2 bits each.
* The next 12 bytes count as 1.5 bits each.
* Anything beyond that counts as 1 bit each.
* Mixed case + non-alphanumeric = up to 6 extra bits.

We actually use a modified version of this calculation that degrades the entropy gained for repeat characters by 75% for
every appearance in the password.  The original NIST calculation is still available in `StrongPassword::EntropyCalculator`
but is generally not used in favor of this stricter (albeit slower) version.

So the EntropyCalculator can calculate the entropy of our password for us.  What else does the algorithm do?

In general the algorithm tries to find the lowest entropy possible for the password by running it against various
filters.  If the lowest entropy we can find for a password is less than the minimum entropy in use by `StrongPassword::StrengthChecker`
then we consider the password to be weak.  The default minimum entropy is 18 bits.

The first thing we try is a lowercased version of the password.

Next we run the password through a `QwertyAdjuster` that tries to adjust the password's entropy by removing common
qwerty keyboard layout passwords such as 'qwertyuiop', '1234567890', or '/.,mnbvcxz'.  It looks for these in chunks
between 3 and 6 in length and reduces the entropy of the password accordingly.

Finally, if specified, we will run the password through a `DictionaryAdjuster`.  This is the slowest part of the
algorithm but adds significantly to the strength checking.  Ideally this should be run against a large dictionary
of the most commong words in your language (e.g. a 300,000 word English dictionary).  Currently I just have this
hard-coded to run against an embedded list of the 500 most common passwords.  This is much faster than running
against a 300,000 dictionary file and still adds considerably to the strength checking.  The password is checked
against all dictionary words over a minimum word length (default is 4).  We also generate variations of
the password to check for common things like leet speak, and qwerty-shifted passwords.  The lowest entropy found
for any variant is used.  Essentially a password of "p4ssw0rd" will be treated as though it were just "password"
when looking for dictionary words and thus would find "password" and get an extremely low entropy value.

You can also supply a list of extra dictionary words to this method via the various `StrongPassword::StrengthChecker`
methods.  Any words supplied will be treated as though they were common dictionary words.  This lets you add
things like your user's first name, last name, and email address as common dictionary words so they will be
disallowed by the strength checker.

## Todo

1. Allow the dictionary of common words to be specified by the user.  This is currently hard-coded to
   the 500 most common passwords.  That also means it's not a true "dictionary" check...
2. Add a common password adjuster that basically works like the existing DictionaryAdjuster but does
   not stop at the first found word.  Stopping at the first word make sense if you have a 300,000 word
   dictionary of the English language but not so much when you're only talking about the 500 most
   common passwords.

## Running the tests

To run the tests, install the gems with `bundle install`. Then run `rake`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Make your changes
4. Test the changes and make sure existing tests pass
5. Commit your changes (`git commit -am 'Add some feature'`)
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request
