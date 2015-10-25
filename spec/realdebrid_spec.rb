require 'spec_helper'

describe RealDebrid::Api do
  # Utilisateur valide pour la connexion à realdebrid
  VALID_USERNAME = ENV['REALDEBRID_VALID_USERNAME'] || ''

  # Mot de passe valide associé à l'utilisateur pour la connexion à realdebrid
  VALID_PASSWORD = ENV['REALDEBRID_VALID_PASSWORD'] || ''

  # Lien à débrider valide (en provenance d'un hoster actuellement fonctionnel)
  VALID_LINK     = ENV['REALDEBRID_VALID_LINK'] || ''

  context 'when login/password is' do
    context 'incorrect' do
      it 'should raise error' do
        expect {
          RealDebrid::Api.new username: 'invalidusername', password: '1024'
        }.to raise_error 'Invalid username and/or password.'
      end
    end

    context 'correct' do
      include_examples 'with successful auth', RealDebrid::Api.new(username: VALID_USERNAME, password: VALID_PASSWORD)
    end
  end

  context 'when cookie is' do
    context 'incorrect' do
      it 'should raise error' do
        expect {
          RealDebrid::Api.new cookie: 'invalidcookie'
        }.to raise_error 'Invalid cookie.'
      end
    end

    context 'correct' do
      include_examples 'with successful auth' do
        let(:realdebrid) {
          realdebrid = RealDebrid::Api.new username: VALID_USERNAME, password: VALID_PASSWORD
          RealDebrid::Api.new(cookie: realdebrid.cookie)
        }
      end
    end
  end

  context 'when cookie and username/password are not set' do
    before { @realdebrid = RealDebrid::Api.new }

    context 'and try to get hosters list' do
      it 'should return hosters' do
        link = @realdebrid.hosters
        expect(link).to be_a Array
      end
    end

    context 'and try to unrestrict a' do
      context 'valid link' do
        it 'should return error code' do
          link = @realdebrid.unrestrict VALID_LINK
          expect(link).to be_a Hash
          expect(link['error']).to eq 1
        end
      end

      context 'invalid link' do
        it 'should return false' do
          link = @realdebrid.unrestrict 'http://www.invalidlink.com'
          expect_error link, [1]
          expect_error @realdebrid.last_error, [1]
        end
      end
    end
  end

  # Valide que le hash passé en paramètre est bien un hash d'erreur contenant un des codes transmis
  #
  # *Params* :
  #   - _Hash_ +hash+
  #   - _Array_ +error_codes+
  def expect_error(hash, error_codes)
    expect(hash).to be_a Hash
    expect(error_codes).to include hash['error']
  end
end
