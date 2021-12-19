# frozen_string_literal: true

require 'faraday'

module DeepHealthCheck
  class HTTPDependencyHealthCheck < DependencyHealthCheck
    CONTENT_TYPE    = 'Content-Type'
    JSON_MIME_TYPE  = 'application/json'

    def initialize
      @type = 'http'
      @dependencies = process_dependencies fetch_dependencies_from_env
    end

    private

    def process_dependencies(dependencies_list)
      threads = dependencies_list.map do |url|
        Thread.new do
          { url.to_s => http_status(url) }
        end
      end

      threads.each(&:join)
      threads.map(&:value).reduce(&:merge)
    end

    def http_status(url)
      response = faraday.get url
      response_body = extract_response_body response
      { status: response.status, details: response_body }
    rescue RuntimeError, Faraday::Error => e
      { status: 503, details: e.inspect }
    end

    def extract_response_body(response)
      unless response.headers[CONTENT_TYPE] == JSON_MIME_TYPE
        return response.body
      end

      require 'json' unless defined?(::JSON)
      JSON.parse(response.body)
    end

    def faraday
      Faraday.new do |builder|
        builder.response(:encoding) if defined?(Faraday::Encoding)
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
