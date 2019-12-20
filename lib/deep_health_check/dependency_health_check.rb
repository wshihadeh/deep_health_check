# frozen_string_literal: true

module DeepHealthCheck
  class DependencyHealthCheck < HealthCheck
    def initialize
      @type = 'abstract'
      @dependencies = nil
      raise 'You are trying to instantiate an abstract class!'
    end

    def call
      return no_dependencies_response if @dependencies.nil?
      api_health_check health_status_code, @dependencies
    end

    private

    def health_status_code
      raise 'health_status_code need to implmented'
    end

    def no_dependencies_response
      api_health_check 200, 'message': "No #{@type.upcase} dependencies defined"
    end

    def fetch_dependencies_from_env
      dependencies = []
      (0..99).each do |i|
        dependencies << ENV[format("#{@type.upcase}_DEPENDENCY_%02d", i)]
      end
      dependencies.compact
    end
  end
end
