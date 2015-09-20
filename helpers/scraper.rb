require 'rubygems'
require 'bundler/setup'
require 'mechanize'
require 'csv'
require 'pry'

require_relative 'location.rb'
require_relative 'glassdoor.rb'

class Scraper
  attr_reader :page, :results

  def initialize

    @agent = Mechanize.new

    # add rate limit of 500ms between requests
    @agent.history_added = Proc.new { sleep 0.5 }

    @glassdoor = Glassdoor.new

  end

  # grabs default search parameters if user has not input any or if the user just hit the page
  def grab_search_params(location)

    params = {}

    params[:'search-text'] = "Web Developer"
    params[:'search-location'] = location
    params[:'start_date'] = Date.today

    verify_search(params, location)

  end

  # verify user inputs for search parameters
  # checks if inputs are empty/nil
  def verify_search(params, location)

    params[:'search-text'] = "Web Developer" if params[:'search-text'].nil? || params[:'search-text'].empty?

    params[:'search-location'] = location if params[:'search-location'].nil? || params[:'search-location'].empty?

    params[:'start-date'] = Date.today if params[:'start-date'].nil? || params[:'start-date'].empty?

    scrap(params)

  end

  def scrap(params)

    # set up parameters
    job = params[:'search-text']
    location = params[:'search-location']
    start_date = params[:'start-date'].to_s

    # enter job and location for search query
    @page = @agent.get("http://www.dice.com/")
    page_form = @page.form_with(:action => '/jobs')
    page_form.q = job
    page_form.l = location

    # all results contain necessary information under one class
    @results = page_form.submit.search(".//div[@class='serp-result-content']")

    # keep the user_input and job_list for html display purposes
    user_input = [job, location, start_date]
    job_list = []

    # build final results
    @results.each do |entry|
      jobs = job_details(entry, start_date)

      unless jobs.nil?
        glassdoor_info = glassdoor_profile(jobs)
        job_list << glassdoor_info
      end

    end

    [user_input, job_list.uniq]

  end

  def job_details(job, start_date)

    job_title = job.at_css('h3 a').text.strip
    company_name = job.at_css('li a').text.strip
    post_link = job.at_css('h3 a').attribute('href').value
    location = job.at_css('li.location').text
    post_date = get_date(job.at_css('li.posted').text)

    return if post_date < start_date

    # capture every instance of characters in between '/' and '/'.  only returns the last value which is the company ID
    company_ID = job.at_css('h3 a').attribute('href').value.scan(/([^\/]*)\//)[-1][0]

    # capture all values before the first question mark
    job_ID = job.at_css('h3 a').attribute('href').value.match(/([^\/]*)\?/)[1]

    details = { title: job_title, company: company_name, link: post_link, location: location, date: post_date, co_id: company_ID, job_id: job_ID }

    details

  end

  def get_date(post_time)

    # gives value of time (e.g. "1" minute, "3" hours)
    value = post_time.split(' ')[0].to_i

    # gives type of time (e.g. 2 "weeks", 6 "hours")
    time_type = post_time.split(' ')[1]

    # returns type of time as singular (e.g. weeks --> week) for case structure
    time_type = time_type[0..-2] if time_type[-1] == "s"

    # strictly returns the date (MM/DD/YYYY)
    case time_type.downcase

      # subtract seconds ago
      when "second"
        Time.at(Time.now.to_i-value).strftime("%Y-%m-%d")

      # subtract minutes ago
      when "minute"
        Time.at(Time.now.to_i-value*60).strftime("%Y-%m-%d")

      # subtract hours ago
      when "hour"
        Time.at(Time.now.to_i-value*60*60).strftime("%Y-%m-%d")

      # subtract days ago
      when "day"
        Time.at(Time.now.to_i-value*60*60*24).strftime("%Y-%m-%d")

      # subtract weeks ago
      when "week"
        Time.at(Time.now.to_i-value*60*60*24*7).strftime("%Y-%m-%d")

    end

  end

  # obtains the glassdoor profile information and appends it to the job details
  def glassdoor_profile(job)

    glassdoor_info = job.dup
    profile = @glassdoor.company_info(job[:company])

    glassdoor_info[:ratings] = profile[:ratings]
    glassdoor_info[:review] = profile[:review]

    glassdoor_info

  end

  # saves results to a CSV file
  def save_results(jobs)

    CSV.open('dice_job_directory.csv', 'w') do |csv|
      jobs.each do |job|
        csv << job
      end
    end

  end

end

# test.grab_search_params("Great Neck")