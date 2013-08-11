if defined? Service::Client::Adapter::Faraday
  require 'qs/request/tracker/faraday_middleware'

  class Service::Client::Adapter::Faraday
    alias _before_qs_request_tracker_service_client_extension_initialize initialize
    def initialize(*args)
      _before_qs_request_tracker_service_client_extension_initialize(*args)
      existing_builder = @builder
      @builder = lambda do |faraday|
        faraday.request :request_id
        existing_builder ? existing_builder.call(faraday) : true
      end
    end
  end
end