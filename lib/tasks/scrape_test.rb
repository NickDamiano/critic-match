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

	def scrape_reviews(movie_uri)
		review_collection = []
		page = @agent.get(movie_uri)
		reviews = page.search("#mantle_skin .pad_top1")
		reviews.each_with_index do |review, i|
			score = reviews[i].search(".metascore_w")

			# Not all author's have their own page so we check
			author_uri = reviews[i].search(".author a")
			author_uri = author_uri.empty? ? "none" : author_uri[0].attributes["href"].value

			#this unless block is necessary because of occasional ads in the body.
			# gets info about review and pushes it into review_collection hash
			unless score.empty?
				score = score.children[0].text
				author_name = reviews[i].search(".author").children[0].text
				publication_name = reviews[i].search(".source a")[0].text
				publication_uri = reviews[0].search(".source a")[0].attributes["href"].value
				review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
					publication_name: publication_name, publication_uri: publication_uri })
			end


			p 'meow'
		end
		binding.pry 

		p 'hi farty'
	end
end

scraper = ScrapeTest.new
# result = scraper.scrape_for_movies('http://www.metacritic.com/browse/movies/title/dvd')
result = scraper.scrape_reviews("http://www.metacritic.com/movie/500-days-of-summer/critic-reviews")