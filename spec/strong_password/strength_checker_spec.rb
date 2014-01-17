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
          expect(StrengthChecker.new(password).is_strong?(min_entropy: 12)).to be(strength)
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
          expect(StrengthChecker.new(password).is_strong?(min_entropy: 12, use_dictionary: true)).to eq(strength)
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
          expect(StrengthChecker.new(password).is_strong?(use_dictionary: true)).to eq(strength)
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
          expect(StrengthChecker.new(password).is_strong?(min_entropy: 40, use_dictionary: true)).to eq(strength)
        end
      end
    end
  end
end