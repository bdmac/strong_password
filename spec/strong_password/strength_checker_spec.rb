require 'spec_helper'

module StrongPassword
  describe StrengthChecker do
    it 'should accept lower strength passwords with reduced entropy requirement' do
      expect(StrengthChecker.new('blahblah').is_strong?(min_entropy: 12, use_dictionary: true)).to be_true
      expect(StrengthChecker.new('password').is_strong?(min_entropy: 12, use_dictionary: true)).to be_false
      expect(StrengthChecker.new('wwwwwwww').is_strong?(min_entropy: 12, use_dictionary: true)).to be_false
      expect(StrengthChecker.new('adamrugel').is_strong?(min_entropy: 12, use_dictionary: true)).to be_true
      expect(StrengthChecker.new('aB$1').is_strong?(min_entropy: 12, use_dictionary: true)).to be_false
    end
  end
end