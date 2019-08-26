require 'spec_helper'

module StrongPassword
  describe QwertyAdjuster do
    subject(:qwerty_adjuster) { QwertyAdjuster.new(entropy_threshhold: 0) }

    describe '#is_strong?' do
      it 'returns true if the calculated entropy is >= the minimum' do
        allow(subject).to receive_messages(adjusted_entropy: 18)
        expect(subject.is_strong?('password')).to be_truthy
      end

      it 'returns false if the calculated entropy is < the minimum' do
        allow(subject).to receive_messages(adjusted_entropy: 17)
        expect(subject.is_strong?('password')).to be_falsey
      end
    end

    describe '#is_weak?' do
      it 'returns the opposite of is_strong?' do
        allow(subject).to receive_messages(is_strong?: true)
        expect(subject.is_weak?('password')).to be_falsey
      end
    end

    describe '#adjusted_entropy' do
      before(:each) { allow(NistBonusBits).to receive_messages(bonus_bits: 0) }
      {
        'qwertyuio' => 5.5,
        '1234567' => 6,
        'lkjhgfd' => 6,
        '0987654321' => 5.5,
        'zxcvbnm' => 6,
        '/.,mnbvcx' => 5.5,
        'password' => 17.5 # Ensure that we don't qwerty-adjust 'password'
      }.each do |password, bits|
        it "returns #{bits} for '#{password}'" do
          expect(subject.adjusted_entropy(password)).to eq(bits)
        end
      end

      describe 'with a default entropy threshhold' do
        subject(:qwerty_adjuster) { QwertyAdjuster.new }

        it 'returns the higher entropy before running qwerty adjustments' do
          # Default threshhold is equal to the default min_entropy for a strong password (18).
          # When not set we should get the base password's entropy from this (16) instead of the
          # lower qwerty-adjusted entropy (6) indicating we avoided doing additional work in the
          # qwerty adjustment code since we already know the password is weak.
          expect(subject.adjusted_entropy('1234567')).to eq(16)
        end
      end
    end
  end
end
