
require 'open3'

class Varnish
  
    
  
  def initialize(instance="default")
    @instance = instance
    @binary = '/Users/jcolby/projects/varnish-rest-api/varnishadm'

  end
  
  ### load yaml config
  
  ### set defaults
  
  ### variables
  
  # secret key
  # varnish version
  # admin port
  
  ### methods
  

  
  # banner
  
  # varnishadm
  
  # list backends
  
  # ban list
  
  # ban all (purge)
  
  # backend enable/disable
  
  # params show
  
  # status
  def status
    varnishadm("status")  
  end
  
  def varnishadm(cmd)
    #stdin, stdout, stderr = Open3.popen3(@binary + " " + cmd)
    #puts "std_out: " + stdout.readlines.join('-')
    #puts "std_err: " + stderr.readlines.join('-')
    
    Open3.popen3(@binary + ' ' + cmd) do |stdin, stdout, stderr, wait_thr|
      puts "std_out: " + stdout.readlines.join('-')
      puts "std_err: " + stderr.readlines.join('-')
      
      exit_status = wait_thr.value
      unless exit_status.success?
        abort "FAILED !!! #{cmd}"
      end
    end
    
  end
  
  def to_s
    "instance #{@instance}"
  end
  
  private :varnishadm
  
end

v = Varnish.new

v.status