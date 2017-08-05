require 'mechanize'
require 'pry-byebug'


class ScrapeTest

	attr_accessor :agent

	def initialize
		@agent = Mechanize.new
		@agent.user_agent_alias = 'Mac Firefox'
	end

	def scrape(uri)
		page = @agent.get(uri)
	end

	def scrape_for_movies(uri)
		movies_uri = []
		page = @agent.get(uri)
		# gets array of movies
		movies = page.search("#mantle_skin .title a")
		movies.each_with_index do |movie, i| 
			movie_uri = page.search("#mantle_skin .title a")[i].attributes["href"].value
			movies_uri.push(movie_uri)
		end
		p movies_uri
	end
end

scraper = ScrapeTest.new
result = scraper.scrape_for_movies('http://www.metacritic.com/browse/movies/title/dvd')
p result
