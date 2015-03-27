require 'sinatra/base'
require 'varnish_rest_api/varnish_base'
require 'yaml'

class VarnishRestApi < Sinatra::Application
  
CONFIG_FILE = "varnish_rest_api.yaml"
CONFIG_PATHS = [ '/etc/' + CONFIG_FILE, ENV['HOME'] + '/' + CONFIG_FILE , File.dirname(__FILE__) + '/' + CONFIG_FILE ]
CONFIG = CONFIG_PATHS.detect {|config| File.file?(config) }
  
if !CONFIG
  $stderr.puts "no configuration file found in paths: " + CONFIG_PATHS.join(',')
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

# default configuration
config_default = {
  :bind_ip => '0.0.0.0',
  :port => 4567,
  :mgmt_port => 6082,
  :mgmt_host => 'localhost',
  :secret => '/etc/varnish/secret',
  :varnishadm_path => '/usr/bin/varnishadm',
  :instance => "default",
  :use_zookeeper => false,
  :zookeeper_host => nil,
  :zookeeper_basenode => '/varnish'  
}

config = config_default.merge!(config_file)

varnish = VarnishBase.new(:instance => config[:instance], \
  :zookeeper_host => config[:zookeeper_host], \
  :use_zookeeper => config[:use_zookeeper], \
  :zookeeper_basenode => config[:zookeeper_basenode], \
  :secret => config[:secret], \
  :mgmt_port => config[:mgmt_port], \
  :mgmt_host => config[:mgmt_host], \
  :varnishadm_path => config[:varnishadm_path])

# sinatra configuration
configure do
  set :root, File.dirname(__FILE__)
  set :bind, config[:bind_ip]
  set :port, config[:port]
  set :server, %w[thin mongrel webrick]
  set :show_exceptions, true
end
  
before do
  content_type :json
end

not_found do
  content_type :html
  @status = status.to_i
  erb :help
end

helpers do
end

error do
  'Sorry there was a nasty error - ' + env['sinatra.error'].name
end

['/', '/help', '/usage'].each do |route|
get route do
  content_type :html
  erb :help
end
end

# display the varnish banner containing varnish version information
get '/banner' do
  varnish.banner
end

# run varnishadm ping call to varnish
get '/ping' do
  varnish.ping
end

# report the status of the varnish process
get '/status' do
  varnish.status
end

# display all backends and state
get '/list' do
  varnish.list_backends(:json => true)
end

# purge cache objects using the ban feature
get '/ban' do
  varnish.ban_all
end

# set the health of a backend.  Acceptable actions are "sick" and "auto". Auto indicates the varnish probe should decide whether to send traffic to this backend based on probe health
# only one backend at a time can be changed. This is a safety feature due to varnish-cli greedy and unpredictable expression pattern matching.
get %r{^/(.*?)/(in|out)$} do  
  backend = params[:captures].first
  action = params[:captures].last
  health = action == 'out' ? 'sick' : 'auto'
  backends = varnish.set_health(backend,health)

    if backends.empty?
      content_type :html
      halt 400, erb(:error, :locals => { :message => "No backend found for pattern #{backend}"}) 
    elsif backends.class == Hash && backends.has_key?("error")
      content_type :html
      error = backends['error']
      halt 400, erb(:error, :locals => { :message => error}) 
    end
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
run! if app_file == $0
end