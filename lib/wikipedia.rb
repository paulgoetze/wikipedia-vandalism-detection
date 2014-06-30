require 'open-uri'
require 'nokogiri'
require 'timeout'

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

  # Retries to call the request in the case of Timeout errors
  def self.request_with_retry(uri, times = 1, timeout = 5)
    content = ""

    begin
      Timeout::timeout(timeout) do
        content = URI.parse(uri).read
      end
    rescue Timeout::Error
      if times > 0
        times -= 1
        retry
      else
        raise Timeout::Error,  "#{times} times retrying request failed."
      end
    end

    content
  end

  def api_request(params = {})
    uri = URI::encode(api_base_uri + param_string(params))
    content = request_with_retry(uri, 3)
    Nokogiri::XML(content)
  end

  def wikitrust_request(params = {})
    uri = URI::encode(wikitrust_base_uri + param_string(params))
    request_with_retry(uri, 3)
  end

  module_function :api_request, :wikitrust_request
end