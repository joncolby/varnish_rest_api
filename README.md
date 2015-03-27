# varnish-rest-api

## Overview

A small RESTful HTTP API for [Varnish](<https://www.varnish-cache.org>) written with [Sinatra](<http://www.sinatrarb.com/intro.html>).  It is designed to be run on the varnish node(s) since it executes varnishadm on the varnish node itself.  It can be started as a stand-alone server using Thin, or as a rack-aware application.  

#### Features

* REST calls output JSON 
* (optional) use zookeeper to register varnish nodes
* configurable with a yaml configuration file and sane defaults


### Getting Started

#### Installing

*NOTE: It is recommended to use a ruby version manager such as [rvm](<https://rvm.io/>) instead of installing with the system ruby. With a ruby version manager, you can prevent "contaminating" your system-level ruby installation by creating an isolated ruby environment independent of system-installed ruby libraries. Plus, on some systems, installing gems at the system level may require root privileges.*

```
gem install varnish_rest_api
```

#### Running

An executable script is included in the gem and will be added to your $PATH after installation. To run as a standalone ruby executable, using Thin or WEBrick. This method is suitable for trying out the rest-api :

```
$ varnishrestapi.rb

using configuration file: /home/vagrant/.rvm/gems/ruby-2.2.1@gemtest/gems/varnish_rest_api-0.0.2/lib/varnish_rest_api.yaml
varnishadm command line: /usr/bin/varnishadm -T localhost:6082 -S /home/vagrant/secret
[2015-03-27 14:17:58] INFO  WEBrick 1.3.1
[2015-03-27 14:17:58] INFO  ruby 2.2.1 (2015-02-26) [x86_64-linux]
== Sinatra (v1.4.6) has taken the stage on 10001 for development with backup from WEBrick
[2015-03-27 14:17:58] INFO  WEBrick::HTTPServer#start: pid=14591 port=10001
```

The usage documentation is available at the root context:

```
http://your-ip-address:10001/
```

#### WORD OF WARNING

This small web application is meant to run in an controlled environment and offers no encryption or authentication.  Anyone who can access the Rest API can potentially remove all of your varnish backends or overload your vanish process with calls to the "varnishadm" command. Use at your own risk!

### Configuration

Configuration settings are stored in a file called **varnish_rest_api.yaml**. The default, example configuration can be found in the [github](<https://github.com/joncolby/varnish_rest_api/tree/master/lib>) repo or on your local system in the installed gem location.

This file is search for in the following paths in this order.  The first file found is used:

* **/etc/varnish_rest_api.yaml**
* **HOME-DIR-OF-PROCESS-USER/varnish_rest_api.yaml**
* **GEMFILE-PATH/lib/varnish_rest_api.yaml**


```
$gem contents varnish_rest_api

..
/usr/lib/ruby/gems/1.8/gems/varnish_rest_api-0.0.2/lib/varnish_rest_api.yaml
..

```


*(defaults which are configured in the application)*
```
---
port: 10001
bind_ip: '0.0.0.0'
secret: /etc/varnish/secret
mgmt_port: 6082
mgmt_host: localhost
varnishadm_path: /usr/bin/varnishadm
instance: default
environment: production
use_zookeeper: false
zookeeper_host: zookeeper_host:2181
zookeeper_basenode: /varnish
```


### RESTful API 
 


| Method  | Url | Description | Remarks | 
|------|------|------|------|
| GET | /list   | list all backends | read-only |
| GET | /ping | ping varnish process  | read-only | 
| GET | /banner | display varnish banner with version information | read-only |
| GET | /status | display status of varnish process | read-only | 
| GET | /ban | ban all objects immediately | effectively purges objects. See varnish [documentation](<https://www.varnish-cache.org/docs/3.0/tutorial/purging.html>) | 
| GET | /*backend*/in | sets backend health to "auto", allowing probe to decide if backend is healthy | use partial or complete backend name as it appears in VCL. The Rest API will not process request if more than one backend is found matching for the pattern |  
| GET | /*backend*/out | sets backend health to "sick" | use partial or complete backend name as it appears in VCL. The Rest API will not process request if more than one backend is found matching for the pattern|  