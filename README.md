# Qs::Request::Tracker

[![Build Status](https://travis-ci.org/quarter-spiral/qs-request-tracker.png)](https://travis-ci.org/quarter-spiral/qs-request-tracker)

Manages a ``Request-Id`` for each HTTP request. Hooks transparently into [Faraday](https://github.com/lostisland/faraday) and [service-client](https://github.com/quarter-spiral/service-client) to pass request ids on to subsequent calls to other services. This way errors can be tracked through all layers and apps of your infrastructure easily.

## Use as a Rack middleware

The easiest way to add request ids to your system is to add the ``Qs::Request::Tracker::Middleware`` as a middleware to your app.

```ruby
require 'qs/request/tracker'

Rack::Builder.new do
  use Qs::Request::Tracker::Middleware
  run YourApp.new
end
```

This will add the request id to the response. If there is no ``Request-Id`` HTTP header set in the request it will also set that. Please note that all middlewares that are included before it will not have that header set!

## Use the Faraday middleware

If you are using [Faraday](https://github.com/lostisland/faraday) you transparently add the request id to all outgoing HTTP calls, too.

```ruby
require 'faraday'
# make sure to require this middleware after faraday itself
require 'qs/request/tracker/faraday_middleware'

conn = Faraday.new(:url => 'http://example.com') do |faraday|
  # it is important to have the request_id middleware inserted before any Faraday adapter
  faraday.request :request_id
end
```

All requests done by that connection will now have a ``Request-Id`` http header set that equal the one from the request that came into your system. If this is used not within a request context that header will just not get set.

**Imporant:** This feature relies on [thread local variables](http://www.ruby-doc.org/core-2.0/Thread.html#label-Fiber-local+vs.+Thread-local) and will not work if you deal with more than one request per thread at a time!

This approach is inspired by [Andy](https://github.com/adelcambre)'s [talk](http://www.youtube.com/watch?v=NpTT30wLL-w) on debugging large scale systems.

## Use the service-client extension

This extension will automatically use the Faraday middleware for [service-client](https://github.com/quarter-spiral/service-client) connections that use the ``Service::Client::Adapter::Faraday`` adapter.

```ruby
require 'service-client'
# make sure to require this extension after service-client itself
require 'qs/request/tracker/service_client_extension'

client = Service::Client.new('http://example.com/')
client.urls.add(:root, :get, "/")
client.get(client.urls.root, oauth_token)
```

This will then heave the ``Request-Id`` http header set through the Faraday middleware.