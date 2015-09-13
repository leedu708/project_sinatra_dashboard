require 'json'
require 'httparty'
require 'pry-byebug'

class Location

  include HTTParty

  base_uri "http://www.telize.com/"

  def initialize

    @ip = self.class.get("/geoip/")

  end

  def grab_location

    response = JSON.parse(@ip.body)
    location = response["city"]

  end

end