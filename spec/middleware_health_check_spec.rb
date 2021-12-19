# frozen_string_literal: true

require 'json'

describe DeepHealthCheck::MiddlewareHealthCheck do
  let(:app) { ->(env) { [200, env, 'app'] } }

  let :middleware do
    DeepHealthCheck::MiddlewareHealthCheck.new(app)
  end

  describe 'db_health' do
    it 'will respond with db_helath end_point' do
      code, env, body = middleware.call env_for('/db_health')
      json_response = JSON.parse(body.first)

      expect(code).to eq(200)
      expect(env['Content-Type']).to eq('application/json')
      expect(json_response).to be_a Hash
      expect(json_response['data']).to be_a Hash
      expect(json_response['data']['type']).to eq 'checker'
      expect(json_response['data']['attributes'].size).to eq 7
    end
  end

  describe 'health' do
    it 'will respond with health end_point' do
      code, env, body = middleware.call env_for('/health')
      json_response = JSON.parse(body.first)

      expect(code).to eq(200)
      expect(env['Content-Type']).to eq('application/json')
      expect(json_response).to be_a Hash
      expect(json_response['data']).to be_a Hash
      expect(json_response['data']['type']).to eq 'checker'
      expect(json_response['data']['attributes'].size).to eq 1
      expect(json_response['data']['attributes']['message']).to eq 'OK'
    end
  end

  describe 'tcp_dependencies_health' do
    let(:dependencies) do
      [
        '127.0.0.1:8080',
        '127.0.0.1:9090',
        '127.0.0.1:8089'
      ]
    end
    let(:dependencies_keys) { dependencies.map { |m| m.tr(':', '_') } }
    let(:up) { { 'message' => 'UP' } }
    let(:down) { { 'message' => 'DOWN' } }

    context 'No depemndecies configured' do
      it 'will respond with No dependencies defined ' do
        code, env, body = middleware.call env_for('/tcp_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'
        expect(
          json_response['data']['attributes']['message']
        ).to eq 'No TCP dependencies defined'
      end
    end

    context 'all checks are green' do
      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_00')
                                  .and_return(dependencies[0])
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_01')
                                  .and_return(dependencies[1])
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_02')
                                  .and_return(dependencies[2])
        allow(Net::Telnet).to receive(:new).and_return(true)
      end
      it 'will respond with 200 and up status for all dependencies' do
        code, env, body = middleware.call env_for('/tcp_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'

        attributes = json_response['data']['attributes']
        expect(attributes.size).to eq 3
        expect(attributes.keys).to eq dependencies_keys
        expect(attributes.values.uniq).to eq [up]
      end
    end

    context 'some checks are down' do
      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_00')
                                  .and_return(dependencies[0])
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_01')
                                  .and_return(dependencies[1])
        allow(ENV).to receive(:[]).with('TCP_DEPENDENCY_02')
                                  .and_return(dependencies[2])

        allow(Net::Telnet).to receive(:new).and_return(true)
        allow(Net::Telnet).to receive(:new).with(hash_including(
                                                   'Host' => '127.0.0.1',
                                                   'Port' => '8089'
                                                 )).and_raise('boom')
      end

      it 'will respond with 200 and the status for each of the  dependencies' do
        code, env, body = middleware.call env_for('/tcp_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'

        attributes = json_response['data']['attributes']
        expect(attributes.size).to eq 3
        expect(attributes.keys).to eq dependencies_keys
        expect(attributes[dependencies_keys[0]]).to eq(up)
        expect(attributes[dependencies_keys[1]]).to eq(up)
        expect(attributes[dependencies_keys[2]]).to eq(down)
      end
    end
  end

  describe 'http_dependencies_health' do
    let(:dependencies) do
      [
        'http://127.0.0.1:8080/health',
        'http://127.0.0.1:9090/health',
        'http://127.0.0.1:8089/health'
      ]
    end
    let(:up) { { 'status' => 200, 'details' => 'up' } }
    let(:down) { { 'status' => 200, 'details' => 'down' } }

    context 'No depemndecies configured' do
      it 'will respond with No dependencies defined ' do
        code, env, body = middleware.call env_for('/http_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'
        expect(
          json_response['data']['attributes']['message']
        ).to eq 'No HTTP dependencies defined'
      end
    end

    context 'all checks are green' do
      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_00')
                                  .and_return(dependencies[0])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_01')
                                  .and_return(dependencies[1])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_02')
                                  .and_return(dependencies[2])
        farady = double('farady')
        response = double('response')

        allow(Faraday).to receive(:new).and_return(farady)
        allow(farady).to receive(:get).and_return(response)
        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return('up')
        allow(response).to receive(:headers).and_return({})
      end

      it 'will respond with 200 and up status for all dependencies' do
        code, env, body = middleware.call env_for('/http_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'

        attributes = json_response['data']['attributes']
        expect(attributes.size).to eq 3
        expect(attributes.keys).to eq dependencies
        expect(attributes.values.uniq).to eq [up]
      end
    end

    context 'all checks are green with json response' do
      let(:check_respose) do
        { 'data' => {
          'attributes' => { 'message' => 'OK' },
          'id' => '1',
          'type' => 'checker'
        } }
      end
      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_00')
                                  .and_return(dependencies[0])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_01')
                                  .and_return(dependencies[1])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_02')
                                  .and_return(dependencies[2])
        farady = double('farady')
        response = double('response')

        allow(Faraday).to receive(:new).and_return(farady)
        allow(farady).to receive(:get).and_return(response)
        allow(response).to receive(:status).and_return(200)
        allow(response).to receive(:body).and_return(check_respose.to_json)
        allow(response).to receive(:headers).and_return(
          'Content-Type' => 'application/json'
        )
      end

      it 'will respond with 200 and up status for all dependencies' do
        code, env, body = middleware.call env_for('/http_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'

        attributes = json_response['data']['attributes']
        expect(attributes.size).to eq 3
        expect(attributes.keys).to eq dependencies
        expect(attributes.values.uniq).to eq [{
          'details' => check_respose,
          'status' => 200
        }]
      end
    end
    context 'some checks are down' do
      before do
        allow(ENV).to receive(:[]).and_return(nil)
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_00')
                                  .and_return(dependencies[0])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_01')
                                  .and_return(dependencies[1])
        allow(ENV).to receive(:[]).with('HTTP_DEPENDENCY_02')
                                  .and_return(dependencies[2])
        farady = double('farady')

        up_response = double('up_response')
        down_response = double('down_response')

        allow(Faraday).to receive(:new).and_return(farady)

        allow(farady).to receive(:get).with(dependencies[0])
                                      .and_return(up_response)
        allow(farady).to receive(:get).with(dependencies[1])
                                      .and_return(down_response)
        allow(farady).to receive(:get).with(dependencies[2])
                                      .and_raise('boom')

        allow(up_response).to receive(:status).and_return(200)
        allow(up_response).to receive(:body).and_return('up')
        allow(up_response).to receive(:headers).and_return({})
        allow(down_response).to receive(:status).and_return(200)
        allow(down_response).to receive(:body).and_return('down')
        allow(down_response).to receive(:headers).and_return({})
      end

      it 'will respond with 200 and the status for each of the  dependencies' do
        code, env, body = middleware.call env_for('/http_dependencies_health')
        json_response = JSON.parse(body.first)

        expect(code).to eq(200)
        expect(env['Content-Type']).to eq('application/json')
        expect(json_response).to be_a Hash
        expect(json_response['data']).to be_a Hash
        expect(json_response['data']['type']).to eq 'checker'

        attributes = json_response['data']['attributes']
        expect(attributes.size).to eq 3
        expect(attributes.keys).to eq dependencies

        expect(attributes[dependencies[0]]).to eq(up)
        expect(attributes[dependencies[1]]).to eq(down)
        expect(attributes[dependencies[2]]).to eq(
          'status' => nil,
          'details' => '#<RuntimeError: boom>'
        )
      end
    end
  end

  describe 'unknown' do
    it 'will return not process the request' do
      code, env, response = middleware.call env_for('/unknown')

      expect(code).to eq(200)
      expect(env['PATH_INFO']).to eq('/unknown')
      expect(env['Content-Type']).to eq nil
      expect(env['rack.version']).to eq [1, 3]
      expect(response).to eq 'app'
    end
  end

  def env_for(url, opts = {})
    Rack::MockRequest.env_for(url, opts)
  end
end
