require 'bundler'
Bundler.require
require_relative 'models/model.rb'
class MyApp < Sinatra::Base

  get '/' do
    erb :index
  end
  
  get '/about' do
    erb :about
  end
  
  post '/city' do
    
    term= params[:search]
    location = params[:location]
    @answer=search(term,location)
    erb :results
  end
  
  post '/new' do
    search=params[:search]
    @news=news(search)
    @weather=weather(search)
    erb :results
  end
end