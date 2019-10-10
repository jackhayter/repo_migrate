require 'decathlon/https'

class Bitbucket

  attr_accessor :auth_token, :username, :password, :organization

  def initialize(username:, password:, organization: nil)
    self.username = username
    self.password = password
    self.organization = organization || username
  end

  def repositories
    http_request(path: 'repositories/' + organization, verb: :get, params: { pagelen: 100 }).dig(:body, :values)
  end

  private

  def base_url
    'https://api.bitbucket.org/2.0/'
  end

  def auth_header
    {
      'Authorization' => 'Basic ' + credentials
    }
  end

  def credentials
    Base64.strict_encode64(username + ':' + password)
  end

  def http_request(path:, verb: :get, params: {})
    Decathlon::HTTPS.json_api_request(
      base_url: base_url + path,
      verb: verb,
      params: params,
      headers: auth_header,
      return_http_status_code: true
    )
  end
end
