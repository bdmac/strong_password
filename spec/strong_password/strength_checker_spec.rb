require 'spec_helper'

module StrongPassword
  describe StrengthChecker do
    context 'with lowered entropy requirement and no dictionary checking' do
      {
        'blahblah' => true,
        'password' => true,
        'wwwwwwww' => false,
        'adamruge' => true,
        'aB$1' => false
      }.each do |password, strength|
        it "is_strong? returns #{strength} for '#{password}' with 12 bits of entropy" do
          expect(StrengthChecker.new(min_entropy: 12).is_strong?(password)).to be(strength)
        end
      end
    end

    context 'with lowered entropy requirement and dictionary checking' do
      {
        'blahblah' => true,
        'password' => false,
        'wwwwwwww' => false,
        'adamruge' => false,
        'madaegur' => true,
        'aB$1' => false
      }.each do |password, strength|
        it "is_strong? returns #{strength} for '#{password}' with 12 bits of entropy" do
          expect(StrengthChecker.new(min_entropy: 12, use_dictionary: true).is_strong?(password)).to eq(strength)
        end
      end
    end

    context 'with standard entropy requirement and dictionary checking' do
      {
        'blahblah' => false,
        'password' => false,
        'wwwwwwww' => false,
        'adamruge' => false,
        'aB$1' => false,
        'correct horse battery staple' => true
      }.each do |password, strength|
        it "is_strong? returns #{strength} for '#{password}' with standard bits of entropy" do
          expect(StrengthChecker.new(use_dictionary: true).is_strong?(password)).to eq(strength)
        end
      end
    end

    context 'with crazy entropy requirement and dictionary checking' do
      {
        'blahblah' => false,
        'password' => false,
        'wwwwwwww' => false,
        'adamruge' => false,
        'aB$1' => false,
        'correct horse battery staple' => false,
        'c0rr#ct h0rs3 Batt$ry st@pl3 is Gr34t' => true
      }.each do |password, strength|
        it "is_strong? returns #{strength} for '#{password}' with standard bits of entropy" do
          expect(StrengthChecker.new(min_entropy: 40, use_dictionary: true).is_strong?(password)).to eq(strength)
        end
      end
    end

    context 'with long password' do
      let(:strength_checker) { StrengthChecker.new }
      let(:password) { ("ba"*500_000) }
      it 'should be truncated' do
        expect(strength_checker.calculate_entropy(password)).
          to eq(strength_checker.calculate_entropy(password.slice(0, StrengthChecker::PASSWORD_LIMIT)))
      end
    end

    context 'with long extra words' do
      let(:strength_checker) { StrengthChecker.new(use_dictionary: true, extra_dictionary_words: ["a"*1_000_000, "b"*10_000_000, "c"*10]) }
      let(:exta_limit) { StrengthChecker::EXTRA_WORDS_LIMIT }
      it 'should be truncated' do
        expect(DictionaryAdjuster).to receive(:new).with({
            min_word_length: 4,
            extra_dictionary_words:
            ["a"*StrengthChecker::EXTRA_WORDS_LIMIT, "b"*StrengthChecker::EXTRA_WORDS_LIMIT, "c"*10]
          }).and_call_original
        strength_checker.calculate_entropy("$tr0NgP4s$w0rd91d£")
      end
    end
  end
end
