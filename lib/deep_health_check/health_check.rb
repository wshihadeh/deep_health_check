# frozen_string_literal: true

module DeepHealthCheck
  class HealthCheck
    def call
      api_health_check 200, 'message': 'OK'
    end

    private

    def api_health_check(status, payload)
      [status,
       { 'Content-Type' => 'application/json' },
       [{
         'data': {
           'type': 'checker',
           'id': '1',
           'attributes': payload
         }
       }.to_json]]
    end
  end
end
