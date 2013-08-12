if defined? ::Raven::Processor::Processor
  module Qs::Request::Tracker
    class RavenProcessor < ::Raven::Processor::Processor
      def process(data)
        if data && data['sentry.interfaces.Http'] && data['sentry.interfaces.Http']['headers'] && data['sentry.interfaces.Http']['headers'][Qs::Request::Tracker::HTTP_HEADER_FIELD]
          data['tags'] ||= {}
          data['tags']['request-id'] = data['sentry.interfaces.Http']['headers'][Qs::Request::Tracker::HTTP_HEADER_FIELD].to_s.gsub('-', '')
        end
        data
      end
    end
  end
end