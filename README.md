# varnish-rest-api

## Overview

A small RESTful HTTP API for [Varnish](<https://www.varnish-cache.org>) written with [Sinatra](<http://www.sinatrarb.com/intro.html>).  It is designed to be run on the varnish node(s) since it executes varnishadm on the varnish node itself.  It can be started as a stand-alone server using Thin, or as a rack-aware application.  

#### Features

* REST calls output JSON 
* (optional) use zookeeper to register varnish nodes
* configurable with a yaml configuration file and sane defaults


## Getting Started

### Installing

*NOTE: It is recommended to use a ruby version manager such as [rvm](<https://rvm.io/>) instead of installing with the system ruby. With a ruby version manager, you can prevent "contaminating" your system-level ruby installation by creating an isolated ruby environment independent of system-installed ruby libraries. Plus, on some systems, installing gems at the system level may require root privileges.*

```
gem install varnish_rest_api
```

### Configuration

Configuration settings are stored in a file called **varnish_rest_api.yaml**. The default, example configuration can be found in the [github](<https://github.com/joncolby/varnish_rest_api/tree/master/lib>) repo or on your local system in the installed gem location.

This file is search for in the following paths in this order.  The first file found is used:

* **/etc/varnish_rest_api.yaml**
* **HOME-DIR-OF-PROCESS-USER/varnish_rest_api.yaml**
* **GEMFILE-PATH/lib/varnish_rest_api.yaml**

To locate and copy the default yaml configuration:

```
$gem contents varnish_rest_api |grep yaml$
..
/usr/lib/ruby/gems/1.8/gems/varnish_rest_api-0.0.2/lib/varnish_rest_api.yaml
..

$cp /usr/lib/ruby/gems/1.8/gems/varnish_rest_api-0.0.2/lib/varnish_rest_api.yaml ~/

```

copy the secret file:

```
sudo cp /etc/varnish/secret ~
sudo chown <username> ~/secret
sudo chmod 0600 ~/secret
```

*(defaults configured in the application)*
```
---
port: 10001  <-- port server will run on  (standalone mode)
bind_ip: '0.0.0.0'   <-- this will bind the server to all interfaces (standalone mode)
secret: /etc/varnish/secret  <-- IMPORTANT. This must be a valid,readable path to the varnish "secret" file
mgmt_port: 6082  <-- varnish management port
mgmt_host: localhost <-- varnish management ip
varnishadm_path: /usr/bin/varnishadm  <-- path to varnishadm binary
instance: default  <-- if more than one instance configured, specify instance name
use_zookeeper: false  <-- zookeeper can be used to report available vanrish nodes
zookeeper_host: zookeeper_host:2181
zookeeper_basenode: /varnish
```


### Running


#### Standalone executable

An executable script is included in the gem and will be added to your $PATH after installation. The standalone executable uses Thin/WEBrick.

```
$ varnishrestapi.rb

using configuration file: /home/vagrant/.rvm/gems/ruby-2.2.1@gemtest/gems/varnish_rest_api-0.0.2/lib/varnish_rest_api.yaml
varnishadm command line: /usr/bin/varnishadm -T localhost:6082 -S /home/vagrant/secret
[2015-03-27 14:17:58] INFO  WEBrick 1.3.1
[2015-03-27 14:17:58] INFO  ruby 2.2.1 (2015-02-26) [x86_64-linux]
== Sinatra (v1.4.6) has taken the stage on 10001 for development with backup from WEBrick
[2015-03-27 14:17:58] INFO  WEBrick::HTTPServer#start: pid=14591 port=10001
```

#### Rackup

create a config.ru file with the following contents:

```
require 'rubygems'
require 'sinatra'
set :environment, ENV['RACK_ENV'].to_sym
disable :run, :reload
require 'varnish_rest_api'
run VarnishRestApi
```

Start server with the rackup command:

```
$ rackup -p10001 --host 0.0.0.0 config.ru
using configuration file: /etc/varnish_rest_api.yaml
varnishadm command line: /usr/bin/varnishadm -T localhost:6082 -S /home/vagrant/secret
Thin web server (v1.6.3 codename Protein Powder)
Maximum connections set to 1024
Listening on 0.0.0.0:10001, CTRL+C to stop
192.168.33.1 - - [28/Mar/2015:14:36:18 +0000] "GET / HTTP/1.1" 200 1905 0.0199
```
#### Example using Nginx/Passenger

Install nginx with passenger support.  Excellent documentation available here: [Passenger documentation](<https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#bundler_support>) and [nginx centos how-to](<https://www.digitalocean.com/community/tutorials/how-to-compile-nginx-from-source-on-a-centos-6-4-x64-vps>)

##### Concise How-to (nginx yum installation method)

Install passenger gem:

```
$gem install passenger
```

configure passenger support for nginx with provided script:

```
$passenger-install-nginx-module
```

create the following directory structure for the application:

```
/var/www/varnishapi
  |
  +-- config.ru <-- see rackup example above for contents
  |
  +-- public/
  |
  +-- tmp/
```

make sure these lines are in your nginx.conf:

```
...
http {

    types_hash_bucket_size 64;
    server_names_hash_bucket_size 128;

    passenger_root /home/vagrant/.rvm/gems/<your-active-rvm-ruby>/gems/passenger-5.0.5;
    passenger_ruby /home/vagrant/.rvm/gems/<your-active-rvm-ruby>/wrappers/ruby
...

...
server {
        listen       80;
        server_name  localhost;

        root /var/www/varnishapi/public;
        passenger_enabled on;        
...        
```

start nginx and verify running processes:

```
$ passenger-memory-stats
...
----- Passenger processes -----
PID    VMSize    Private  Name
-------------------------------
14717  351.3 MB  0.9 MB   PassengerAgent watchdog
14720  628.9 MB  1.4 MB   PassengerAgent server
14725  222.9 MB  0.8 MB   PassengerAgent logger
14741  285.7 MB  2.2 MB   Passenger AppPreloader: /var/www/varnishapi
14761  354.4 MB  12.2 MB  Passenger RubyApp: /var/www/varnishapi/public
14768  354.5 MB  9.8 MB   Passenger RubyApp: /var/www/varnishapi/public
14775  352.6 MB  2.3 MB   Passenger RubyApp: /var/www/varnishapi/public
...
```

### Usage Documentation
The usage documentation is available at the root context:

```
http://your-ip-address:10001/
```

### WORD OF WARNING!

This small web application is meant to run in an controlled environment and offers no encryption or authentication.  Anyone who can access the Rest API can potentially remove all of your varnish backends or overload your vanish process with calls to the "varnishadm" command. Use at your own risk!



### RESTful API Actions
 


| Method  | Url | Description | Remarks | 
|------|------|------|------|
| GET | /list   | list all backends | read-only |
| GET | /ping | ping varnish process  | read-only | 
| GET | /banner | display varnish banner with version information | read-only |
| GET | /status | display status of varnish process | read-only | 
| GET | /ban | ban all objects immediately | effectively purges objects. See varnish [documentation](<https://www.varnish-cache.org/docs/3.0/tutorial/purging.html>) | 
| GET | /*backend*/in | sets backend health to "auto", allowing probe to decide if backend is healthy | use partial or complete backend name as it appears in VCL. The Rest API will not process request if more than one backend is found matching for the pattern |  
| GET | /*backend*/out | sets backend health to "sick" | use partial or complete backend name as it appears in VCL. The Rest API will not process request if more than one backend is found matching for the pattern|  