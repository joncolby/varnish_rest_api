$LOAD_PATH.unshift(File.dirname(__FILE__))
  
require 'sinatra'
require 'varnish'
require 'yaml'

CONFIG_PATHS = [ '/etc/varnishapi/varnishapi.yaml', ENV['HOME'] + '/varnishapi.yaml', File.dirname(__FILE__) + '/varnishapi.yaml']
CONFIG = CONFIG_PATHS.detect {|config| File.file?(config) }
  
if !CONFIG
  $stderr.puts "no configuration file found paths: " + CONFIG_PATHS.join(',')
  exit!
else
  puts "using configuration file: " + CONFIG
end

config_parsed = begin
  YAML.load(File.open(CONFIG))
rescue ArgumentError, Errno::ENOENT => e
  $stderr.puts "Exception while opening yaml config file: #{e}"
  exit!
end

config_file = Hash.new
begin
  config_file = config_parsed.inject({}){|h,(k,v)| h[k.to_sym] = v; h}
rescue NoMethodError => e
  $stderr.puts "error parsing configuration yaml"
end

config_default = {
  :bind_ip => '0.0.0.0',
  :port => 4567,
  :mgmt_port => 6082,
  :mgmt_host => 'localhost',
  :secret => '/etc/varnish/secret',
  :varnishadm_path => '/usr/bin/varnishadm',
  :instance => "default",
  :environment => 'production',
  :use_zookeeper => false,
  :zookeeper_host => nil,
  :zookeeper_basenode => '/varnish'  
}

config = config_default.merge!(config_file)

varnish = Varnish.new(:instance => config[:instance], \
  :zookeeper_host => config[:zookeeper_host], \
  :use_zookeeper => config[:use_zookeeper], \
  :zookeeper_basenode => config[:zookeeper_basenode], \
  :secret => config[:secret], \
  :mgmt_port => config[:mgmt_port], \
  :mgmt_host => config[:mgmt_host], \
  :varnishadm_path => config[:varnishadm_path])

# sinatra configuration
set :bind, config[:bind_ip]
set :port, config[:port]
  
before do
  content_type :txt
end

get '/' do
  "usage"
end

get '/banner' do
  varnish.banner
end

get '/ping' do
  varnish.ping
end

get '/status' do
  varnish.status
end

get '/list' do
  varnish.list_backends(:json => true)
end

get '/ban' do
  varnish.ban_all
end

get '/:backend/in' do
  varnish.set_health(params[:backend],'auto')
  redirect to('/list')
end

get '/:backend/out' do
  varnish.set_health(params[:backend],'sick')
  redirect to('/list')
end



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
