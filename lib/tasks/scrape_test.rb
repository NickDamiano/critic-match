require 'mechanize'


class ScrapeTest

	attr_accessor :agent

	def initialize
		@agent = Mechanize.new
		@agent.user_agent_alias = 'Mac Firefox'
	end

	def scrape(uri)
		page = @agent.get(uri)
	end
end

scraper = ScrapeTest.new
result = scraper.scrape('http://www.metacritic.com/browse/movies/title/dvd')
p result
