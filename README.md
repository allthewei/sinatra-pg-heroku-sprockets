sinatra-postgreSQL-heroku-sprockets
===

This repo is my sinatra boilerplate. Using postgreSQL as database and deploy to heroku. Assets management based on sprockets
In this repo. I make a sampe app for demo (https://sinatra-pg-heroku-sprockets.herokuapp.com/). Following is how I make this project step by step.
Feel free to clone this repo directly. Just remove the demo code (view & model) you don't need and you'll have a production-ready sinatra project setup! 


### Initial setup

Create Gemfile for rubygems
```
touch Gemfile
```
```
#Gemfile
source  "https://rubygems.org"

gem  "sinatra"
gem  "sinatra-contrib"
gem  "pry-byebug"
gem  "better_errors"
gem  "binding\_of\_caller"
gem  "activerecord"
gem  "sinatra-activerecord"
gem  'sinatra-flash'
gem  'sinatra-redirect-with-flash'
gem  'rake'
gem  'pg'
gem  'sprockets'
```
```
bundle install
```

Create main app
```
touch app.rb
```
app.rb serves as a role of routes and controller 

```rb
# app.rb
require "sinatra"
require "sinatra/reloader"  if development?
require "pry-byebug"
require "better_errors"
require 'sinatra/activerecord'
configure :development  do
  use BetterErrors::Middleware
  BetterErrors.application_root  =  File.expand_path('..', __FILE__)
end

get '/'  do
  'Hello world!!!'
end
```
```rb
rackup
```
Now You can see "Hello world" at http://localhost:9292/.

### Assets Management

We don't want just a "Hello world". We want to render a view. 
Let's say: I want to render a index.
Comment out the 'Hello world!!!' in app.rb and create a views folder for placing erb view files.

```
mkdir views
```
```
touch views/index.erb
```
Now. You can write some code at index.erb and do some test to check the connection of view and routes.
You can also try to add another page. e.g. about page.

```rb
# app.rb
get '/about'  do
  erb :about
end
```
```
touch views/about.erb
```

What if we have common components for these pages? For example, navbar and footer.
We can create a layout.erb.
layout.erb contents will be rendered at every page. And use <%= yield %> to render the content for specific route.

```html
<html>
  <head>
    <meta  charset="UTF-8">
    <meta  name="viewport"  content="width=device-width, initial-scale=1.0">
    <meta  http-equiv="X-UA-Compatible"  content="ie=edge">
    <link  rel="stylesheet"  href="assets/style.css">
  </head>
  <body>
    <div  class="navbar"  style="background: blue">Navbar</div>
    <%= yield %>
    <div  class="footer"  style="background: red">Footer</div>
  </body>
</html>
```
Usually, the navbar and footer are not that simple. Any better wat to organize the messy code? We can make partial files to deal with it: 

```
touch views/_navbar.erb
touch views/_footer.erb
```
```html
<!-- views/_navbar.erb -->
<div  class="navbar"  style="background: red">Navbar</div>
```
```html
<!-- views/_footer.erb -->
<div  class="navbar"  style="background: blue">Footer</div>
```
```html
<!-- layout.erb -->
<html>
  <head>
    <meta  charset="UTF-8">
    <meta  name="viewport"  content="width=device-width, initial-scale=1.0">
    <meta  http-equiv="X-UA-Compatible"  content="ie=edge">
  </head>
  <body>
    <div  class="navbar"  style="background: blue">Navbar</div>
    <%= yield %>
    <div  class="footer"  style="background: red">Footer</div>
  </body>
</html>

```
We know how to organize the html now. How about CSS/JavaScript?
We create 'assets' folder to handle these files.

For example,

```
app
├── Gemfile
├── app.rb
├── assets
│   ├── javascripts
│   │   ├── index.js
│   └── stylesheets
│       └── style.scss
└── views
    ├── index.erb
    └── layout.erb
```
Use Sprockets to handling assets is a good practice for me.
Since there are often some loading assets issue occur after deploying app to live. And Sprockets features declarative dependency management for JavaScript and CSS assets, as well as a powerful preprocessor pipeline that allows you to write assets in languages like CoffeeScript, Sass and SCSS.

```rb
gem 'sprockets' # we already bundle it at beginning
```

You can refer to: [Sinatra Recipes - Asset Management - Sprockets](http://recipes.sinatrarb.com/p/asset_management/sprockets)

```
touch config.ru
```
```rb
# config.ru
require 'sinatra/base'
  require './app'
  require 'sprockets'
  map '/assets' do
    environment = Sprockets::Environment.new
    environment.append_path 'assets/javascripts'
    environment.append_path 'assets/stylesheets'
    run environment
  end
  
map '/' do
  run Sinatra::Application
end
```
```html
<!-- layout.erb -->
<html>
  <head>
    <meta  charset="UTF-8">
    <meta  name="viewport"  content="width=device-width, initial-scale=1.0">
    <meta  http-equiv="X-UA-Compatible"  content="ie=edge">
    <link  rel="stylesheet"  href="assets/style.css">
  </head>
  <body>
    <%=  erb(:_navbar) %>
    <%=  yield  %>
    <%=  erb(:_footer) %>
  </body>
  <script  src="assets/index.js"></script>
</html>
```
```js
// assets/javascripts/index.js
console.log("JS from assets/javascripts/index.js");
```


Go check http://localhost:9292/. You will find all the assets are connected!

### Database congig and Rakefile

We need some config to deal with database for development and production stage

```
mkdir config
```
```
touch config/environment.rb
```
```rb
configure :production, :development  do
db  =  URI.parse(ENV['DATABASE_URL'] ||  'postgres://localhost/mydb')

  ActiveRecord::Base.establish_connection(
    :adapter  =>  db.scheme  ==  'postgres'  ?  'postgresql' : db.scheme,
    :host  =>  db.host,
    :username  =>  db.user,
    :password  =>  db.password,
    :database  =>  db.path[1..-1],
    :encoding  =>  'utf8'
    )
end

```
```
touch config/database.yml
```
```yml
# database.yml

development:
  adapter:  postgresql
  encoding:  unicode
  database:  mydb
  pool:  2

production:
  adapter:  postgresql
  encoding:  unicode
  pool:  5
  host:  <%= ENV['DATABASE_HOST'] %>
  database:  <%= ENV['DATABASE_NAME'] %>
```
```
touch Rakefile
```
Create a Rakefile to make us can use rake console 

```rb
# Rakefile

require './app'
require 'sinatra/activerecord'
require 'sinatra/activerecord/rake'
require_relative 'config/environment'

task :console  do
  Pry.start
end
```
### Example code: a post model

Now, let's create a simple post model.
First, use rake -T to check the rake tasks.
```
rake -T
```
Create a migration for create posts table

```
rake db:create_migration NAME=create_posts
```
in the migration file...

```rb
class  CreatePosts < ActiveRecord::Migration[5.2]
  def  change
    create_table :posts  do |t|
      t.string :title
      t.text :content
      t.timestamps
    end
  end
end
```
run db:migrate and schema will be produced automatically.

```
rake db:migrate
```
Create Post model.

```
mkdir models
touch models/post.rb
```
```rb
# post.rb
class  Post < ActiveRecord::Base

end
```
in app.rb, include the model

```rb
#app.rb
require_relative './models/post'
```
Now, you can check rake console and Post model already connected with database.
Here, I make a simple form for user to post at index page.

```rb
# app.rb

get '/'  do
  @posts  =  Post.all
  erb :index 

end

post '/post'  do
  @post  =  Post.new(title: params[:title], content: params[:content])
  @post.save
  redirect '/'
end
```

```html
<!-- index.erb -->
<h2>Sinatra-PG-Heroku</h2>
  <form  action="/post"  method="post">
    <input  type="text"  name="title"  placeholder="title">
    <input  type="text"  name="content"  placeholder="content">
    <input  type="submit">
  </form>
<table>
  <tr>
    <th>Title</th>
    <th>Content</th>
  </tr>
  <% @posts.each do |post| %>
  <tr>
    <td><%= post.title %></td>
    <td><%= post.content %></td>
  </tr>
  <% end %>
</table>
```
It's time to deploy the app on heroku!

```
heroku login
heroku create YOUR_APP_NAME
git push heroku master
heroku run rake db:migrate
```

Boom! Your sinatra app with postrgrelSQL database live now.
























