require 'json'
require 'httparty'

class Glassdoor

  include HTTParty
  base_uri = "http://api.glassdoor.com"
  partner_id = ENV['PARTNER_ID']
  api = ENV['GLASSDOOR_KEY']

  def initialize

    @options = { query: { :'t.p' => partner_id,
                          :'t.k' => api,
                          :userip => "0.0.0.0",
                          :format => 'json',
                          :v => '1',
                          :action => 'employers' 
                        }
                }

  end

end