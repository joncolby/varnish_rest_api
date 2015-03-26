# varnish-rest-api

## Overview

A small RESTful HTTP API for [Varnish](<https://www.varnish-cache.org>) written with [Sinatra](<http://www.sinatrarb.com/intro.html>).  It is meant to be run on the varnish node(s) since it executes varnishadm on the node.  It can be started as a stand-alone server using Thin, and is rack-aware.  

#### Features

* REST calls output JSON 
* (optional) use zookeeper to register varnish nodes
* configurable with a yaml configuration file and sane defaults


### Getting Started

#### Installing

#### Running

### Configuration

Configuration settings are stored in a file called **varnish-rest-api.yaml**

This file is search for in the following paths in this order.  The first file found is used:

* **/etc/varnish-rest-api.yaml**
* **HOME-DIR-OF-PROCESS-USER/varnish-rest-api.yaml**
* **GEMFILE-PATH/lib/varnish-rest-api.yaml**

varnish-rest-api.yaml

*(defaults which are configured in the application)*
```
---
port: 4567
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
| GET | /list   | sdfg | sdfg |
| GET | /ping | sfdg | sdfg | 
| GET | /banner | sfdg | sfg  |
| GET | /status | sfdg | sfg  | 
| GET | /ban | sfdg | sfg  | 
| GET | /*backend*/in | sfdg | sfg  |  
| GET | /*backend*/out | sfdg | sfg  |  