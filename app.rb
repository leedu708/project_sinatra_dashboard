require 'sinatra'
require 'pry'
require_relative 'helpers/scraper.rb'
require_relative 'helpers/glassdoor.rb'
require_relative 'helpers/location.rb'

helpers LocationHelper

enable :sessions

get '/' do

end