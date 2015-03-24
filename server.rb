$LOAD_PATH.unshift(File.dirname("."))
  
require 'sinatra'
require 'varnish'

varnish = Varnish.new

before do
  content_type :txt
end

get '/ping' do
  varnish.ping
end

get '/list' do
  varnish.list_backends(:json => true)
end

get '/ban' do
  varnish.ban_all
end


# set_health





=begin
v = Varnish.new
puts v.status
puts "="
puts v.banner
puts "="
puts v.list_backends(:expression => "server3", :json=>true)
puts "="
puts v.list_backends(:expression => "server2",:json=>true) 
puts v.set_health("server11","sick")
puts v.set_health("server3","auto")
puts v.set_health("server","auto",false)
puts "="
puts v.ping
puts "="
puts v.ban_all
=end