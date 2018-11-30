require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require 'sinatra/activerecord'
require_relative './models/post'
configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

get '/' do
    @posts = Post.all
    # 'Hello world!!!'
    erb :index # render a view
end

get '/about' do
    erb :about 
end

post '/post' do
  @post = Post.new(title: params[:title], content: params[:content])
  @post.save
  redirect '/'
end