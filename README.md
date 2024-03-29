# DeepHealthCheck

[![Gem Version](https://badge.fury.io/rb/deep_health_check.svg)](https://badge.fury.io/rb/deep_health_check)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](http://opensource.org/licenses/MIT)
[![Build Status](https://travis-ci.org/wshihadeh/deep_health_check.svg?branch=master)](https://travis-ci.org/wshihadeh/deep_health_check)
[![Depfu](https://badges.depfu.com/badges/b29d275b0743e77163a813ac51251be9/count.svg)](https://depfu.com/github/wshihadeh/deep_health_check?project_id=10389)
![Codecov](https://img.shields.io/codecov/c/github/wshihadeh/deep_health_check)


A simple Health status API

# Getting Started

Install gem
~~~sh
 # Gemfile
 gem 'deep_health_check'
~~~

Add middleware before Rails::Rack::Logger to prevent false positive response
if other middleware fails when database is down for example ActiveRecord::QueryCache

~~~sh
 # config/application.rb
 config.middleware.insert_after "Rails::Rack::Logger", DeepHealthCheck::MiddlewareHealthCheck
~~~

Or for protecting all endpoits with hatauth 

~~~sh
# config/application.rb
config.middleware.use DeepHealthCheck::BasicAuthHealthCheck  do |username, password|
  username == "$USER" && password == "$PASS"
end
~~~


# Protect Health Check endpoints using htauth credentials.
Health check middleware expose the following endpoints
  - /health
  - /db_health
  - /tcp_dependencies_health
      + dependencies must follow the below format and can be coonfigured using envioronment varables such as:
       ```sh
       # TCP_DEPENDENCY_${00..99}=${ip_or_host}:${port}
       TCP_DEPENDENCY_00=127.0.0.0:8080
       ```
  - /http_dependencies_health
      + dependencies must be valid http url and can be coonfigured using envioronment varables such as:
       ```sh
       # HTTP_DEPENDENCY_${00..99}=${ip_or_host}:${port}
       HTTP_DEPENDENCY_00=http://127.0.0.0:8080/health
       ```

Some of these endpoints provide information about the database and system status. By Default these endpoints are not protected and are accessible publicly. To reduce the security risk introduced by exposing these endpoints, We can protect them using htauth credentials. The following page provide all the necessary steps needed to achieve this task using nginx.

[Nginx Configurations](NGINX.md)
