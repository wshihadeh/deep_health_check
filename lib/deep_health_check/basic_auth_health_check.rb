# frozen_string_literal: true

module DeepHealthCheck
  class BasicAuthHealthCheck < Rack::Auth::Basic
    def call(env)
      auth = ::Rack::Auth::Basic::Request.new(env)
      if env['PATH_INFO'].match(/^\/((db|tcp|http)_)?(dependencies_)?health$/)
        return unauthorized unless auth.provided?
        return bad_request unless auth.basic?

        if valid?(auth)
          env['REMOTE_USER'] = auth.username
          health_check = HealthCheckBuilder.build env['PATH_INFO']
          return (health_check&.call || @app.call(env))
        end

        unauthorized
      else
        @app.call(env)
      end
    end
  end
end
