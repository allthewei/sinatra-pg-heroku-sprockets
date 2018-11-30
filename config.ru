require 'sinatra/base'
require './app'
require 'sprockets'

map '/assets' do
    # Sprockets::Environment class to access and serve assets from your application:
    environment = Sprockets::Environment.new 
    environment.append_path 'assets/javascripts'
    environment.append_path 'assets/stylesheets'
    run environment
end
  
map '/' do
  run Sinatra::Application
end