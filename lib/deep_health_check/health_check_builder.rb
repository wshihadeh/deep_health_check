# frozen_string_literal: true

module DeepHealthCheck
  class HealthCheckBuilder
    def self.build(check)
      case check
      when '/health'
        HealthCheck.new
      when '/db_health'
        DBHealthCheck.new
      when '/tcp_dependencies_health'
        TCPDependencyHealthCheck.new
      when '/http_dependencies_health'
        HTTPDependencyHealthCheck.new
      end
    end
  end
end
