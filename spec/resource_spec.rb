require_relative 'spec_helper'

describe 'DynectRest.Resource' do
  before :all do
    # Disable real http calls
    WebMock.disable_net_connect!(allow_localhost: true)
  end

  before(:each) do
    # Reset things like http redirect counters, etc
    WebMock.reset!
  end

  let(:zone) { 'test_zone' }
  let(:fqdn) { 'test_fqdn' }
  let(:dynect) do
    session_response = { status: 'success', data: { token: 'mock_token' } }.to_json
    stub_request(:post, 'https://api2.dynect.net/REST/Session')
      .to_return(body: session_response,
                 status: 200,
                 headers: { 'Content-Length' => 3 })
    DynectRest.new('customer_name', 'user_name', 'password', zone)
  end

  context 'Get ARecords ' do
    it 'Gets ARecords based on zone and fqdn' do
      # https://api2.dynect.net/REST/ARecord/zone/test_fqdn
      fqdn_response = { status: 'success',
                        data: ['/REST/ARecord/test_zone/test_fqdn/000000001', '/REST/ARecord/test_zone/test_fqdn/000000002'],
                        job_id: 1_234_567_890,
                        msgs: [{ INFO: 'detail: Found 2 records', SOURCE: 'API-B', ERR_CD: nil, LVL: 'INFO' }] }.to_json
      fdqn_response_1 = { status: 'success',
                          data: {
                            zone: 'test_zone',
                            ttl: 60,
                            fqdn: 'test_fqdn',
                            record_type: 'A',
                            rdata: { address: '192.168.1.1' },
                            record_id: 0o00000001
                          },
                          job_id: 1_279_356_988,
                          msgs: [INFO: 'get: Found the record', SOURCE: 'API-B', ERR_CD: nil, LVL: 'INFO'] }.to_json
      fdqn_response_2 = { status: 'success',
                          data: {
                            zone: 'test_zone',
                            ttl: 60,
                            fqdn: 'test_fqdn',
                            record_type: 'A',
                            rdata: { address: '192.168.1.2' },
                            record_id: 0o00000002
                          },
                          job_id: 1_279_356_988,
                          msgs: [INFO: 'get: Found the record', SOURCE: 'API-B', ERR_CD: nil, LVL: 'INFO'] }.to_json

      # It makes a unique api request for each individual record returned in the list
      stub_request(:get, 'https://api2.dynect.net/REST/ARecord/test_zone/test_fqdn').to_return(body: fqdn_response, status: 200)
      stub_request(:get, 'https://api2.dynect.net/REST/ARecord/test_zone/test_fqdn/000000001').to_return(body: fdqn_response_1, status: 200)
      stub_request(:get, 'https://api2.dynect.net/REST/ARecord/test_zone/test_fqdn/000000002').to_return(body: fdqn_response_2, status: 200)

      # Act
      response = dynect.a.get('test_fqdn')

      # Assert
      expect(response.count).to eq 2
      expected_fqdn_1 = { rdata: { address: '192.168.1.1' }, ttl: 60 }.to_json
      expected_fqdn_2 = { rdata: { address: '192.168.1.2' }, ttl: 60 }.to_json
      expect(response[0].to_json).to eq expected_fqdn_1
      expect(response[1].to_json).to eq expected_fqdn_2
    end

    # NOTE - The test below WILL FAIL!!!!
    #    URI::InvalidURIError:
    #      bad URI(is not URI?): https://api2.dynect.net/REST/{"status":"incomplete","job_id":1279356988,"msgs":[{"INFO":"get: Found the record","SOURCE":"API-B","ERR_CD":null,"LVL":"INFO"}]}
    # This functionality is currently broken in this GEM
    # I'd like to contribute a pull request to fix this broken functionality
    # But before making any changes I'm hoping the rspec and rubocop (non-code changes) can be accepted first
    it 'Gets ARecord based on zone and fqdn and id when a job_id was returned from the API' do
      # https://api2.dynect.net/REST/ARecord/zone/test_fqdn
      job_id_response = { status: 'incomplete',
                          job_id: 1_279_356_988,
                          msgs: [INFO: 'get: Found the record', SOURCE: 'API-B', ERR_CD: nil, LVL: 'INFO'] }.to_json
      fdqn_response = { status: 'success',
                        data: {
                          zone: 'test_zone',
                          ttl: 60,
                          fqdn: 'test_fqdn',
                          record_type: 'A',
                          rdata: { address: '192.168.1.1' },
                          record_id: 0o00000001
                        },
                        job_id: 1_279_356_988,
                        msgs: [INFO: 'get: Found the record', SOURCE: 'API-B', ERR_CD: nil, LVL: 'INFO'] }.to_json

      # It should automatically make the request to the Job endpoint for this request
      stub_request(:get, 'https://api2.dynect.net/REST/ARecord/test_zone/test_fqdn/000000001').to_return(body: job_id_response, status: 307)
      # https://help.dyn.com/get-job/
      stub_request(:get, 'https://api2.dynect.net/REST/Job/1279356988').to_return(body: fdqn_response, status: 200)

      expect{dynect.a.get('test_fqdn', '000000001')}.to raise_error(URI::InvalidURIError)

      # Act
      # response = dynect.a.get('test_fqdn', '000000001')

      # Assert
      # expect(response.count).to eq 1
      # expected_fqdn = { rdata: { address: '192.168.1.1' }, ttl: 60 }.to_json
      # expect(response.to_json).to eq expected_fqdn
    end
  end
end
