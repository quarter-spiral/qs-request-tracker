require 'sinatra'
disable :run

require 'service-client'
require 'rack/client'

require_relative './spec_helper'

require 'qs/request/tracker/service_client_extension'

ALL_REQUESTS = []

class SampleAppServiceClient < Sinatra::Base
  helpers do
    def request_with_service_client!
      client = Service::Client.new('http://example.com/')
      client.urls.add(:test, :get, "/by-client")
      client.raw.adapter = Service::Client::Adapter::Faraday.new(adapter: [:rack, SampleAppServiceClient.new])

      client.get(client.urls.test, 'no-token')

      'done'
    end
  end

  get "/by-client" do
    ALL_REQUESTS << request
    '{"done": true}'
  end

  get "/with-request-id-set" do
    Qs::Request::Tracker.thread_request_id = '123'

    request_with_service_client!
  end

  get "/without-request-id-set" do
    request_with_service_client!
  end
end

describe Qs::Request::Tracker do
  before do
    Qs::Request::Tracker.thread_request_id = nil
    @client = Rack::Client.new do
      run SampleAppServiceClient.new
    end
  end

  it "passes the request-id as a http header" do
    @client.get('/with-request-id-set')
    ALL_REQUESTS.last.env['HTTP_REQUEST_ID'].must_equal '123'
  end

  it "doesn't add a request-id if there is none present" do
    @client.get('/without-request-id-set')
    ALL_REQUESTS.last.env['HTTP_REQUEST_ID'].must_be_nil
  end
end