# frozen_string_literal: true

module DeepHealthCheck
  class MiddlewareHealthCheck
    def initialize(app)
      @app = app
    end

    def call(env)
      health_check = HealthCheckBuilder.build env['PATH_INFO']
      health_check&.call || @app.call(env)
    end
  end
end
