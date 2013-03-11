require 'spec_helper'

module StrongPassword
  describe NistBonusBits do
    describe '.bonus_bits' do
      it 'calculates the bonus bits the first time for a given password' do
        NistBonusBits.reset_bonus_cache!
        NistBonusBits.should_receive(:calculate_bonus_bits_for).and_return(1)
        expect(NistBonusBits.bonus_bits('password')).to eq(1)
      end
      
      it 'caches the bonus bits for a password for later use' do
        NistBonusBits.reset_bonus_cache!
        NistBonusBits.stub(calculate_bonus_bits_for: 1)
        NistBonusBits.bonus_bits('password')
        NistBonusBits.should_not_receive(:calculate_bonus_bits_for)
        expect(NistBonusBits.bonus_bits('password')).to eq(1)
      end
    end
    
    describe '.calculate_bonus_bits_for' do
	    {
	      'Ab$9' => 4,
	      'Ab $9' => 6,
	      'A b $ 9' => 7,
	      'Ab$' => 3,
	      'Ab $' => 5,
	      'A b $ c d' => 6,
	      '1!' => -4,
	      '1 !' => -2,
	      '1 ! 2 # 3 $' => -1,
	      '123' => -8,
	      '1 23' => -6,
	      '1 2 3 4 5 6' => -5,
	      'blah' => -2,
	      'blah blah' => 0,
	      'blah blah blah blah' => 1
	    }.each do |password, bonus_bits|
	      it "returns #{bonus_bits} for '#{password}'" do
	        expect(NistBonusBits.calculate_bonus_bits_for(password)).to eq(bonus_bits)
        end
      end
    end
  end
end