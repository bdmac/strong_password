require 'spec_helper'

module StrongPassword
  describe EntropyCalculator do
    describe '.bits' do
      before(:each) { NistBonusBits.stub(bonus_bits: 0) }
      {
        '' => 0,
        '*' => 4,
        '**' => 6,
        '***' => 8,
        '****' => 10,
        '*****' => 12,
        '******' => 14,
        '*******' => 16,
        '********' => 18,
        '*********' => 19.5,
        '**********' => 21,
        '***********' => 22.5,
        '************' => 24,
        '*************' => 25.5,
        '**************' => 27,
        '***************' => 28.5,
        '****************' => 30,
        '*****************' => 31.5,
        '******************' => 33,
        '*******************' => 34.5,
        '********************' => 36,
        '*********************' => 37,
        '**********************' => 38,
        '***********************' => 39,
        '************************' => 40
      }.each do |password, bits|
        it "returns #{bits} for #{password.length} characters" do
          expect(subject.bits(password)).to eq(bits)
        end
      end
    end
    
    describe '.bits_with_repeats_weakened' do
      before(:each) { NistBonusBits.stub(bonus_bits: 0) }
      {
        '' => 0,
        '*' => 4,
        '**' => 5.5,
        '***' => 6.625,
        '****' => 7.46875,
        '****a' => 9.46875
      }.each do |password, bits|
        it "returns #{bits} for #{password.length} characters" do
          expect(subject.bits_with_repeats_weakened(password)).to eq(bits)
        end
      end
    end
  end
end