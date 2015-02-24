require 'sinatra'
require 'sinatra'
require 'sinatra/reloader'
require 'slim'
require 'json'
require "sinatra/json"
require 'jubatus/classifier/client'


get '/' do
  @result = nil
  @text = ""
  slim :main
end

post '/' do
  cli = Jubatus::Classifier::Client::Classifier.new "127.0.0.1", 9199, "a"
  datum = Jubatus::Common::Datum.new("text" => params["text"])
  @result = cli.classify([datum])[0].sort_by{|x| -x.score}[0].label
  @text = params["text"]
  slim :main
end
