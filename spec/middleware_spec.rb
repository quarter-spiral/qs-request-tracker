require_relative './spec_helper'

require 'sinatra'
disable :run

require 'rack/client'

require 'json'

class SampleAppMiddleware < Sinatra::Base
  use Qs::Request::Tracker::Middleware

  get '/' do
    JSON.dump('request_id' => request.env['HTTP_REQUEST_ID'])
  end
end

def parse_request_id(response)
  JSON.parse(response.body)['request_id']
end

describe Qs::Request::Tracker::Middleware do
  before do
    @client = Rack::Client.new do
      run SampleAppMiddleware.new
    end
    Qs::Request::Tracker.thread_request_id = nil
  end

  it "adds a request id if none is provided via an HTTP request header" do
    response = @client.get '/'
    request_id = parse_request_id(response)
    request_id.wont_be_nil
  end

  it "sets the thread local id" do
    response = @client.get '/'
    Qs::Request::Tracker.thread_request_id.wont_be_nil
  end

  it "sets the request id in the response headers" do
    response = @client.get '/'
    response.headers['Request-Id'].wont_be_nil
  end

  it "does not change the supplied request id" do
    response = @client.get '/', {'Request-Id' => '12345'}
    Qs::Request::Tracker.thread_request_id.must_equal '12345'
    Qs::Request::Tracker.thread_request_id.must_equal '12345'
  end
end