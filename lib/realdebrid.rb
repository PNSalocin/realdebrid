require "realdebrid/version"

module RealDebrid

  class Api

    # URL de base vers real-debrid
    URL_PREFIX_BASE = 'https://real-debrid.com/'

    # Suffixe de connexion
    URL_SUFFIX_LOGIN = 'ajax/login.php'

    # Suffixe de debridage des liens
    URL_SUFFIX_UNRESTRICT = 'ajax/unrestrict.php'

    # Suffixe de récupération des informations du compte
    URL_SUFFIX_ACCOUNT = 'api/account.php'

    # Suffixe de récupération des hosters
    URL_SUFFIX_HOSTERS = 'api/hosters.php'

    attr_accessor :username
    attr_accessor :password
    attr_accessor :cookie

    # Constructeur
    #
    # *Params* :
    #  - _Hash|nil_ +params+ (optionnel) TODO
    def initialize(params = {})
      require 'net/http'

      if params[:cookie]
        self.cookie = params[:cookie]
        raise 'Invalid cookie.' unless self.cookie_valid? cookie
      elsif params[:username] && params[:password]
        self.username = params[:username]
        self.password = params[:password]
        raise 'Invalid username and/or password.' unless self.login
      end
    end

    # Effectue un login (aka une récupération du cookie de connexion) vers real-debrid
    # en fonction des paramètres internes username et password
    #
    # *Raises* :
    #   - _ArgumentError_ : Le couple login/mot de passe est incorrect
    def login
      return false if self.username.nil? || self.password.nil?

      require 'digest/md5'
      params = { user: self.username, pass: Digest::MD5.hexdigest(self.password) }
      response = request "#{URL_PREFIX_BASE}#{URL_SUFFIX_LOGIN}", params

      if response && response['error'] == 0 && response['cookie']
        self.cookie = response['cookie']
        true
      else
        false
      end
    end

    # Effectue une requête de débridage d'un lien passé en paramètre
    #
    # *Params* :
    #   - _String_ +link+ Uri à débrider
    #   - _String_ +password+ (optionnel) Mot de passe
    # *Returns* :
    #   - _Hash|Bool_ : false si la requête à échouée, hash du json décodé dans le cas contraire
    def unrestrict(link, password = nil)
      params = { link: link }
      params['password'] = password if password

      response = request "#{URL_PREFIX_BASE}#{URL_SUFFIX_UNRESTRICT}", params, self.cookie

      if response && response['error'] == 0
        response
      else
        false
      end
    end

    # Retourne les informations associées au compte
    #
    # *Params* :
    #   - _String|nil_ +cookie+ (optionnel) Chaîne du cookie de connexion
    # *Returns* :
    #   - _Bool_ : true si le cookie est valide, false dans le cas contraire
    def account_info(cookie = nil)
      cookie = cookie || self.cookie
      request "#{URL_PREFIX_BASE}#{URL_SUFFIX_ACCOUNT}", { out: 'json' }, cookie
    end

    # Retourne les hosters actuellement actifs
    #
    # *Params* :
    #   - _String|nil_ +cookie+ (optionnel) Chaîne du cookie de connexion
    # *Returns* :
    #   - _Bool_ : true si le cookie est valide, false dans le cas contraire
    def hosters
      request "#{URL_PREFIX_BASE}#{URL_SUFFIX_HOSTERS}"
    end

    # Teste la validité du cookie d'instance par défaut, ou de celui passé en paramètre si existant
    #
    # *Params* :
    #   - _String|nil_ +cookie+ (optionnel) Chaîne du cookie de connexion
    # *Returns* :
    #   - _Bool_ : true si le cookie est valide, false dans le cas contraire
    def cookie_valid?(cookie = nil)
      account_info = self.account_info cookie
      account_info.is_a?(Hash) && account_info['error'].nil?
    end

    private

    # Effectue une requête GET
    #
    # *Params* :
    #   - _String_ +uri+ Uri vers laquelle effectuer la requête
    #   - _Hash_ +params+ (optionnel) Paramètres GET de la requête
    #   - _String_ +cookie+ (optionnel) Cookie de la requête
    # *Returns* :
    #   - _Hash|Bool_ : false si la requête à échouée, hash du json décodé dans le cas contraire
    def request(uri, params = {}, cookie = nil)
      uri = URI.parse uri
      uri.query = URI.encode_www_form params

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Cookie'] = cookie if cookie

      response = http.request request

      if response.is_a?(Net::HTTPSuccess)
        begin
          JSON.parse(response.body)
        rescue
          response.body
        end
      else
        false
      end
    end
  end
end