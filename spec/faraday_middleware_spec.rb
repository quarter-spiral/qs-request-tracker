require 'sinatra'
disable :run
require 'faraday'
require 'rack/client'

require_relative './spec_helper'

require 'qs/request/tracker/faraday_middleware'

ALL_REQUESTS = []

class SampleAppFaraday < Sinatra::Base
  helpers do
    def request_with_faraday!
      conn = Faraday.new(:url => 'http://example.com') do |faraday|
        faraday.request :request_id
        faraday.adapter :rack, SampleAppFaraday.new
      end

      conn.get '/by-client'

      'done'
    end
  end

  get "/by-client" do
    ALL_REQUESTS << request
    '{"done": true}'
  end

  get "/with-request-id-set" do
    Qs::Request::Tracker.thread_request_id = '123'

    request_with_faraday!
  end

  get "/without-request-id-set" do
    request_with_faraday!
  end
end

describe Qs::Request::Tracker do
  before do
    Qs::Request::Tracker.thread_request_id = nil
    @client = Rack::Client.new do
      run SampleAppFaraday.new
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