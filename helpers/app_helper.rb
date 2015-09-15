require_relative 'location.rb'
require_relative 'scraper.rb'

module AppHelper

  # grabs client's city
  # loads location if session already has city parameter input
  def current_location

    if session[:city].nil?
      location = client_location
      save_location(location)
    else
      location = load_location
    end

    location

  end

  def client_scrap(location)

    # creates a new scraper with user inputs
    scraper = Scraper.new
    
    if params.nil?
      search_results = scraper.grab_search_params(location)
    else
      search_results = scraper.verify_search(params, location)
    end

    search_results

  end

  def client_location

    location = Location.new
    location.grab_location

  end

  def save_location(location)

    session[:city] = location

  end

  def load_location

    session[:city]

  end

end