# frozen_string_literal: true

require 'net-telnet'

module DeepHealthCheck
  class TCPDependencyHealthCheck < DependencyHealthCheck
    def initialize
      @type = 'tcp'
      @dependencies = process_dependencies fetch_dependencies_from_env
    end

    private

    def process_dependencies(dependencies_list)
      threads = dependencies_list.map do |item|
        host, port = item.to_s.split(':')
        Thread.new do
          { "#{host}_#{port}" => tcp_telnet_status(host, port) }
        end
      end

      threads.each(&:join)
      threads.map(&:value).reduce(&:merge)
    end

    def health_status_code
      faild_count = @dependencies.select { |_k, v| v == down }.count
      faild_count.zero? ? 200 : 503
    end

    def tcp_telnet_status(host, port)
      return up if Net::Telnet.new(
        'Host' => host,
        'Port' => port,
        'Telnetmode' => false,
        'Prompt' => /^\+OK/n
      )

      down
    rescue StandardError
      down
    end

    def up
      { 'message': 'UP' }
    end

    def down
      { 'message': 'DOWN' }
    end
  end
end
