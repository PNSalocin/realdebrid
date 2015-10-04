require 'spec_helper'

shared_examples 'with successful auth' do |rd|

  let(:realdebrid) { rd }

  context 'and try to unrestrict a' do
    context 'valid link' do
      it 'should return link informations' do
        link = realdebrid.unrestrict VALID_LINK
        expect(link).to be_a Hash
        expect(link['error']).to eq 0
      end
    end

    context 'invalid link' do
      it 'should return false' do
        link = realdebrid.unrestrict 'http://www.invalidlink.com'
        expect(link).to eq false
      end
    end
  end

  context 'and try to get account infos' do
    it 'should return hosters' do
      account_info = realdebrid.account_info
      expect(account_info).to be_a Hash
    end
  end

  context 'and try to get hosters list' do
    it 'should return hosters' do
      hosters = realdebrid.hosters
      expect(hosters).to be_a Array
    end
  end

end