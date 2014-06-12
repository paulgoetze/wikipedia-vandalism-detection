require 'open-uri'
require 'nokogiri'

module Wikipedia

  def self.api_base_uri
    "http://en.wikipedia.org/w/api.php?format=xml&action=query&"
  end

  def self.wikitrust_base_uri
    "http://en.collaborativetrust.com/WikiTrust/RemoteAPI?method=wikimarkup&"
  end

  def self.param_string(params)
    params.map{ |k, v| "#{k}=#{v}" }.join('&')
  end

  def api_request(params = {})
    uri = URI::encode(api_base_uri + param_string(params))
    content = URI.parse(uri).read
    Nokogiri::XML(content)
  end

  def wikitrust_request(params = {})
    uri = URI::encode(wikitrust_base_uri + param_string(params))
    URI.parse(uri).read
  end

  module_function :api_request, :wikitrust_request
end