require 'open-uri'
require 'nokogiri'

module Wikipedia

  def self.api_base_uri
    "https://en.wikipedia.org/w/api.php?format=xml&action=query&"
  end

  def api_request(params = {})
    uri = URI::encode(api_base_uri + params.map{ |k, v| "#{k}=#{v}" }.join('&'))
    content = URI.parse(uri).read
    Nokogiri::XML(content)
  end

  module_function :api_request
end