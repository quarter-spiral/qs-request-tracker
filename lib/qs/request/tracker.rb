require "qs/request/tracker/version"
require "qs/request/tracker/middleware"

module Qs
  module Request
    module Tracker
      THREAD_LOCAL_REQUEST_ID_KEY = :'_HTTP_REQUEST_ID'
      HTTP_HEADER_FIELD = 'Request-Id'

      def self.thread_request_id
        Thread.current[THREAD_LOCAL_REQUEST_ID_KEY]
      end

      def self.thread_request_id=(new_id)
        Thread.current[THREAD_LOCAL_REQUEST_ID_KEY] = new_id
      end
    end
  end
end
