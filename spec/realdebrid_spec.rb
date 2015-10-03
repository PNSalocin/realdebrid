require 'spec_helper'

describe RealDebrid::Api do

  VALID_USERNAME = ''
  VALID_PASSWORD = ''
  VALID_LINK     = ''

  context 'when login/password is' do

    context 'incorrect' do

      it 'should raise error' do
        expect {
          realdebrid = RealDebrid::Api.new username: 'invalidusername', password: '1024'
        }.to raise_error 'Invalid username and/or password.'
      end
    end

    context 'correct' do

      before {
        @realdebrid = RealDebrid::Api.new username: VALID_USERNAME, password: VALID_PASSWORD
      }

      context 'and try to unrestrict a' do

        context 'valid link' do

          it 'should return link informations' do
            link = @realdebrid.unrestrict VALID_LINK
            expect(link).to be_a Hash
          end
        end

        context 'invalid link' do

          it 'should return false' do
            link = @realdebrid.unrestrict 'http://www.invalidlink.com'
            expect(link).to eq false
          end

        end

      end

      context 'and try to get hosters list' do

        it 'should return hosters' do
          link = @realdebrid.hosters
          expect(link).to be_a Array
        end
      end

    end
  end

  context 'when cookie is' do

    context 'incorrect' do

      it 'should raise error' do
        expect {
          realdebrid = RealDebrid::Api.new cookie: 'invalidcookie'
        }.to raise_error 'Invalid cookie.'
      end
    end

    context 'correct' do

      before {
        realdebrid = RealDebrid::Api.new username: VALID_USERNAME, password: VALID_PASSWORD
        @cookie = realdebrid.cookie
      }

      it 'shoudn\t raise error' do
        expect {
          realdebrid = RealDebrid::Api.new cookie: @cookie
        }.not_to raise_error
      end

    end
  end
end
