ENV['RACK_ENV'] ||= 'test'

Bundler.require

require 'qs/request/tracker'

require 'minitest/autorun'