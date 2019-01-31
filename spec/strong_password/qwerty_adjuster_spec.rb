require 'spec_helper'

module StrongPassword
  describe QwertyAdjuster do
    describe '#is_strong?' do
      let(:subject) { QwertyAdjuster.new('password') }

      it 'returns true if the calculated entropy is >= the minimum' do
        allow(subject).to receive_messages(adjusted_entropy: 18)
        expect(subject.is_strong?).to be_truthy
      end

      it 'returns false if the calculated entropy is < the minimum' do
        allow(subject).to receive_messages(adjusted_entropy: 17)
        expect(subject.is_strong?).to be_falsey
      end
    end

    describe '#is_weak?' do
      let(:subject) { QwertyAdjuster.new('password') }

      it 'returns the opposite of is_strong?' do
        allow(subject).to receive_messages(is_strong?: true)
        expect(subject.is_weak?).to be_falsey
      end
    end

    describe '#adjusted_entropy' do
      before(:each) { allow(NistBonusBits).to receive_messages(bonus_bits: 0)}
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
          expect(QwertyAdjuster.new(password).adjusted_entropy).to eq(bits)
        end
      end
    end
  end
end
