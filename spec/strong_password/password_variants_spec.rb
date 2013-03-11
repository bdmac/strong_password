require 'spec_helper'

module StrongPassword
  describe PasswordVariants do
    describe '.all_variants' do
      it 'includes the lowercase password' do
        expect(subject.all_variants("PASSWORD")).to include('password')
      end
      
      it 'includes keyboard shift variants' do
        subject.stub(keyboard_shift_variants: ['foo', 'bar'])
        expect(subject.all_variants("password")).to include('foo', 'bar')
      end
      
      it 'includes leet speak variants' do
        subject.stub(leet_speak_variants: ['foo', 'bar'])
        expect(subject.all_variants("password")).to include('foo', 'bar')
      end
      
      it 'does not mutate the password' do
        password = 'PASSWORD'
        subject.all_variants(password)
        expect(password).to eq('PASSWORD')
      end
    end
    
    describe '.keyboard_shift_variants' do
      it 'returns no variants if password includes only bottom row characters' do
        expect(subject.keyboard_shift_variants('zxcvbnm,./')).to eq([])
      end
      
      it 'maps down-right passwords' do
        expect(subject.keyboard_shift_variants('qwerty')).to include('asdfgh')
      end
      
      it 'includes reversed down-right password' do
        expect(subject.keyboard_shift_variants('qwerty')).to include('hgfdsa')
      end
      
      it 'maps down-left passwords' do
        expect(subject.keyboard_shift_variants('sdfghj')).to include('zxcvbn')
      end
      
      it 'maps reversed down-left passwords' do
        expect(subject.keyboard_shift_variants('sdfghj')).to include('nbvcxz')
      end
    end
    
    describe '.leet_speak_variants' do
      it 'returns no variants if the password includes no leet speak' do
        expect(subject.leet_speak_variants('password')).to eq([])
      end
      
      it 'returns standard leet speak variants' do
        expect(subject.leet_speak_variants('p4ssw0rd')).to include('password')
      end
      
      it 'returns reversed standard leet speak variants' do
        expect(subject.leet_speak_variants('p4ssw0rd')).to include('drowssap')
      end
      
      it 'returns both i and l variants when given a 1' do
        expect(subject.leet_speak_variants('h1b0b')).to include('hibob', 'hlbob')
      end
    end
  end
end