require 'json'
require 'httparty'

class Location

  include HTTParty

  base_uri "http://www.telize.com/"

  def initialize

    # grabs geolocation information
    @ip = self.class.get("/geoip/")

  end

  def grab_location

    # pulls only the city
    response = JSON.parse(@ip.body)
    location = response["city"]

  end

end