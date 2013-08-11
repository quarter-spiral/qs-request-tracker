require 'uuid'

module Qs
  module Request
    module Tracker
      class Middleware
        def initialize(app)
          @app = app
        end

        def call(env)
          env['HTTP_REQUEST_ID'] ||= UUID.new.generate
          Qs::Request::Tracker.thread_request_id = env['HTTP_REQUEST_ID']
          status, headers, body = @app.call(env)
          headers[HTTP_HEADER_FIELD] ||= Qs::Request::Tracker.thread_request_id
          [status, headers, body]
        end
      end
    end
  end
end