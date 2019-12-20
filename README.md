# HealthCheck

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




# Protect Health Check endpoints using htauth credentials.
Health check middleware expose the following endpoints
  - /health
  - /db_health
  - /tcp_dependencies_health
  - /http_dependencies_health

Some of these endpoints provide information about the database and system status. By Default these endpoints are not protected and are accessible publicly. To reduce the security risk introduced by exposing these endpoints, We can protect them using htauth credentials. The following page provide all the necessary steps needed to achieve this task.

[Nginx Configurations](NGINX.md)
