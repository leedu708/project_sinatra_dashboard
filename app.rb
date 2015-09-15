require 'sinatra'
require 'thin'
require_relative 'helpers/scraper.rb'
require_relative 'helpers/glassdoor.rb'
require_relative 'helpers/location.rb'
require_relative 'helpers/app_helper.rb'

helpers AppHelper

enable :sessions

get '/' do

  location = current_location

  scrap_info = client_scrap(location)

  query = scrap_info[0]
  results = scrap_info[1]

  erb :index, :locals => { :location => location, :query => query, :results => results, :today => Date.today }

end