$LOAD_PATH.unshift(File.dirname("."))
  
require 'sinatra'
require 'varnish'


get '/' do
  "Hello World"
end