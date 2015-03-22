
require 'open3'
require 'json'
require 'ostruct'
 
class Backend < OpenStruct
#  def to_json
#    table.to_json
#  end
#  def as_json(options = nil)
#    super.as_json(options)
#  end
end

class Varnish

  def initialize(instance="default")
    @instance = instance
    #@binary = '/Users/jcolby/varnish-rest-api/varnishadm'
    #@binary = './varnishadm'
    @binary = '/usr/bin/varnishadm -T :6082 -S /home/vagrant/secret'


  end
  
  ### load yaml config  
  ### set defaults
  
  ### variables
  
  # secret key
  # varnish version
  # admin port
  
  
  # ban list
  
  def ping
    JSON.pretty_generate({ 'ping' => varnishadm("ping")})
  end
  
  # ban all (purge)
  
  # backend enable/disable
  def set_health(backend,health)    
    unless ["sick","auto"].include?(health)
      return JSON.pretty_generate({ 'error' => "invalid health '#{health}'. health must be 'sick' or 'auto'"})
    end
    
    backends_found = list_backends(:expression => backend)

    if backends_found.size > 1
      return JSON.pretty_generate({ 'error' => "multiple backends found for pattern '#{backend}': " +  backends_found.collect { |b| b.backend_name }.join(',')})
    end
    
    varnishadm("backend.set_health #{backend} #{health}")    
    list_backends(:expression => backend, :json => true)
  end
      
  def list_backends(options={})
   default_options = {
    :expression => nil,
    :json => false
    }
    options = default_options.merge!(options)
    backends = Array.new
    command = "backend.list"
    
    unless options[:expression].nil? || options[:expression].empty?
      command += " #{options[:expression]}"
    end
    #puts "command => " + command
    varnishadm(command).to_a.each_with_index do |line,i| 
      next if i < 1
      backend = Backend.new
      #server1(127.0.0.1,80) 1 probe Sick 0/5 
      #line = "server1(127.0.0.1,80) 1 probe Sick 0/5"
      components = line.squeeze.split
      host_re = /(.*?)\((.*?)\)\s+(\d+)\s+(.*?)\s+(.*)/
      match = host_re.match(line)
      backend.backend_name = match[1].to_s
      backend.host = match[2].to_s
      backend.refs = match[3].to_s
      backend.admin = match[4].to_s
      backend.health = match[5].to_s

      #backends << (options[:json] ? backend.to_json : backend)
      backends << backend
    end
    options[:json] ? JSON.pretty_generate(backends.map { |o| Hash[o.each_pair.to_a] }) : backends
  end
  
  def banner
    JSON.pretty_generate({ 'banner' => varnishadm("banner")})
  end
  
  def status
    JSON.pretty_generate({ 'status' => varnishadm("status")}) 
  end
  
  def varnishadm(cmd)    
    begin
      Open3.popen3(@binary + ' ' + cmd) do |stdin, stdout, stderr, wait_thr|        

        output = Array.new 
        
        unless wait_thr.value.success?
          #raise
          $stderr.puts "varnishadm exited with code #{exit_status.exitstatus}"
          while line = stderr.gets
            $stderr.puts line
            if line.strip.length > 0
              output << line.strip
            end
          end
        end
        
        while line = stdout.gets
          if line.strip.length > 0          
            output << line.strip
          end
        end        
        return output
      end
      
    rescue Errno::ENOENT => e
      $stderr.puts "error running varnishadm: #{e.message}"
      return []
    end      
  end

  def to_s
    "instance #{@instance}"
  end
  
  private :varnishadm
  
end

v = Varnish.new

puts v.status
puts "="
puts v.banner
puts "="
puts v.list_backends(:expression => "server3", :json=>true)
puts "="
puts v.list_backends(:expression => "server2",:json=>true) 
#puts v.set_health("server3","sick")
#puts v.set_health("server3","auto")
#puts v.set_health("server","auto")
puts "="
puts v.ping
