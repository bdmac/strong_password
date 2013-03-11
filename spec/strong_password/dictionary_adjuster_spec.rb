require 'spec_helper'

module StrongPassword
  describe DictionaryAdjuster do
    describe '#is_strong?' do
      let(:subject) { DictionaryAdjuster.new('password') }

      it 'returns true if the calculated entropy is >= the minimum' do
        subject.stub(adjusted_entropy: 18)
        expect(subject.is_strong?).to be_true
      end
      
      it 'returns false if the calculated entropy is < the minimum' do
        subject.stub(adjusted_entropy: 17)
        expect(subject.is_strong?).to be_false
      end
    end
    
    describe '#is_weak?' do
      let(:subject) { DictionaryAdjuster.new('password') }

      it 'returns the opposite of is_strong?' do
        subject.stub(is_strong?: true)
        expect(subject.is_weak?).to be_false
      end
    end
    
    describe '#adjusted_entropy' do
      before(:each) { NistBonusBits.stub(bonus_bits: 0)}
      
      it 'checks against all variants of a given password' do
        password = 'password'
        adjuster = DictionaryAdjuster.new(password)
        PasswordVariants.should_receive(:all_variants).with(password).and_return([])
        adjuster.adjusted_entropy
      end
      
      {
        'bnm,./' => 14, # Qwerty string should not get adjusted by dictionary adjuster
        'h#e0zbPas' => 19.5, # Random string should not get adjusted by dictionary adjuster
        'password' => 4, # Adjusts common dictionary words
        'E_!3password' => 11.5, # Adjusts common dictionary words regardless of placement
        'h#e0zbPas 32e2i81 password' => 31.3125, # Even if there are multiple words
        '123456' => 4, # Even if they are also qwerty strings
        'password123456' => 16 # But only drops the first matched word
      }.each do |password, bits|
        it "returns #{bits} for '#{password}'" do
          expect(DictionaryAdjuster.new(password).adjusted_entropy).to eq(bits)
        end
      end
    end
  end
end