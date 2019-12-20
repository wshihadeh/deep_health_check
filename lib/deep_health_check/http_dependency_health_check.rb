# frozen_string_literal: true

require 'faraday'
require 'faraday_middleware'

module DeepHealthCheck
  class HTTPDependencyHealthCheck < DependencyHealthCheck
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

    def health_status_code
      failed = @dependencies.any? do |_name, response|
        !response[:status] || response[:status] >= 300
      end
      failed ? 503 : 200
    end

    def http_status(url)
      response = faraday.get url
      { status: response.status, details: response.body }
    rescue RuntimeError, Faraday::Error => e
      { status: nil, details: e.inspect }
    end

    def faraday
      Faraday.new do |builder|
        builder.response :json, content_type: /\bjson$/
        builder.response(:encoding) if defined?(Faraday::Encoding)
        builder.adapter Faraday.default_adapter
      end
    end
  end
end
