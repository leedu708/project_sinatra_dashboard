require 'json'
require 'httparty'
require 'figaro'
require 'pry'
require 'yaml'

class Glassdoor

  include HTTParty
  base_uri = "http://api.glassdoor.com"
  PID = "43525"
  API_KEY = "eHu6ltJqjMm"

  # returns hash of company information
  def company_info(company)

    # Checks if there is actually a response as some entries may have no reviews
    response = grab_info(company)

    if response.nil? || response["industry"] == "Staffing & Outsourcing"

      profile = { name: "none", ratings: "none", review: "none" }

    else
      profile = { name: company, ratings: grab_ratings(response), review: featured_review(response) }

    end

    profile

  end

  def grab_info(company)

    # grabs reviews
    response = self.class.get("http://api.glassdoor.com/api/api.htm?t.p=#{PID}&t.k=#{API_KEY}&userip=0.0.0.0&useragent=&format=json&v=1&action=employers&q=#{company}&ps=1")

    employers = response["response"]["employers"]

    if employers.empty?

      info = nil

    else

      info = employers[0]

    end

    info

  end

  def grab_ratings(response)

    # parses the response
    { count: response["numberOfRatings"],
      overall: response["overallRating"],
      culture: response["cultureAndValuesRating"],
      leadership: response["seniorLeadershipRating"],
      compensation: response["compensationAndBenefitsRating"],
      opportunity: response["careerOpportunitiesRating"],
      worklife: response["workLifeBalanceRating"]
    }

  end

  def featured_review(response)

    response["featuredReview"] || "none"

  end

end