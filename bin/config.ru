
require 'varnish_rest_api'
require 'sinatra'

set :environment, ENV['RACK_ENV'].to_sym

run VarnishRestApi
