if defined? Faraday::Middleware
  module Qs::Request::Tracker
    class FaradayMiddleware < Faraday::Middleware
      THREAD_LOCAL_MISMATCH_MESSAGES = "REQUEST TRACKING ERROR! Found an ID in the headers: %s but a different one in the thread locals: %s"

      def initialize(app, options = {})
        super(app)
      end

      def call(env)
        annotate_env_with_request_id!(env) if thread_local_request_id
        @app.call(env)
      end

      protected
      def annotate_env_with_request_id!(env)
        log_request_mismatch_error(env) unless request_ids_match?(env)
        env[:request_headers][HTTP_HEADER_FIELD] = thread_local_request_id
      end

      def request_ids_match?(env)
        return true unless headers_request_id(env)
        (thread_local_request_id && thread_local_request_id == headers_request_id(env))
      end

      def thread_local_request_id
        Qs::Request::Tracker.thread_request_id
      end

      def headers_request_id(env)
        env[:request_headers][HTTP_HEADER_FIELD]
      end

      def log_request_mismatch_error(env)
        STDERR.puts(THREAD_LOCAL_MISMATCH_MESSAGES % [thread_local_request_id.inspect, headers_request_id(env).inspect])
      end
    end
  end

  if Faraday.respond_to? :register_middleware
    Faraday.register_middleware :request, :request_id => lambda { Qs::Request::Tracker::FaradayMiddleware }
  end
end