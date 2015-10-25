require 'realdebrid/version'

# https://real-debrid.com/
module RealDebrid

  # Permet, après authentification, de principalement débrider des liens, de récupérer les informations du compte
  # et de récupérer la liste des hosters
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

    # Nom d'utilisateur realdebrid
    attr_accessor :username

    # Mot de passe realdebrid
    attr_accessor :password

    # Cookie de connexion realdebrid
    attr_accessor :cookie

    # Constructeur
    #
    # *Params* :
    #  - _Hash|nil_ +params+
    # *Raises* :
    #   - _StandardError_ : Le couple login/mot de passe est incorrect
    def initialize(params = {})
      require 'net/http'

      if params[:cookie]
        self.cookie = params[:cookie]
        fail 'Invalid cookie.' unless self.cookie_valid?
      elsif params[:username] && params[:password]
        self.username = params[:username]
        self.password = params[:password]
        fail 'Invalid username and/or password.' unless login
      end
    end

    # Effectue un login (aka une récupération du cookie de connexion) vers real-debrid
    # en fonction des paramètres username et password
    #
    # *Returns* :
    #   - _Bool_ : true si la connexion a reussie, false dans le cas contraire
    def login
      return false if username.nil? || password.nil?

      require 'digest/md5'
      params = { user: username, pass: Digest::MD5.hexdigest(password) }
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
    #   - _Hash|Array|String|Bool_ : false si la requête à échouée, un objet/tableau correspondant json décodé
    #                                (ou une chaîne si celui-ci n'a pu l'être) dans le cas contraire
    def unrestrict(link, password = nil)
      params = { link: link }
      params['password'] = password if password

      response = request "#{URL_PREFIX_BASE}#{URL_SUFFIX_UNRESTRICT}", params, cookie

      puts response.inspect
      if response && response['error'] == 0
        response
      else
        false
      end
    end

    # Retourne les informations associées au compte
    #
    # *Returns* :
    #   - _Hash|Array|String|Bool_ : false si la requête à échouée, un objet/tableau correspondant json décodé
    #                                (ou une chaîne si celui-ci n'a pu l'être) dans le cas contraire
    def account_info
      request "#{URL_PREFIX_BASE}#{URL_SUFFIX_ACCOUNT}", { out: 'json' }, cookie
    end

    # Retourne les hosters actuellement actifs
    #
    # *Returns* :
    #   - _Hash|Array|String|Bool_ : false si la requête à échouée, un objet/tableau correspondant json décodé
    #                                (ou une chaîne si celui-ci n'a pu l'être) dans le cas contraire
    def hosters
      hosters = request "#{URL_PREFIX_BASE}#{URL_SUFFIX_HOSTERS}"
      parse_json "[#{hosters}]"
    end

    # Teste la validité de l'actuel cookie
    #
    # *Returns* :
    #   - _Bool_ : true si le cookie est valide, false dans le cas contraire
    def cookie_valid?
      account_info = self.account_info
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
    #   - _Hash|Array|String|Bool_ : false si la requête à échouée, un objet/tableau correspondant json décodé
    #                                (ou une chaîne si celui-ci n'a pu l'être) dans le cas contraire
    def request(uri, params = {}, cookie = nil)
      uri = URI.parse uri
      uri.query = URI.encode_www_form params

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      request = Net::HTTP::Get.new uri.request_uri
      request['Cookie'] = cookie if cookie

      response = http.request request

      response.is_a?(Net::HTTPSuccess) ? parse_json(response.body) : false
    end

    # Tente de parser le JSON passé en paramètre
    #
    # *Params* :
    #   - _String_ +json_string+ JSON à décoder
    # *Returns* :
    #   - _Hash|Array|String_ : JSON décodé ou la forme d'un tableau ou d'un objet,
    #                           ou bien la chaîne d'origine si elle n'a pu être décodée
    def parse_json(json_string)
      require 'json'
      JSON.parse json_string
    rescue
      json_string
    end
  end
end
