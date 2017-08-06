# require 'mechanize'
# require 'pry-byebug'


# class ScrapeTest

# 	attr_accessor :agent

# 	def initialize
# 		@agent = Mechanize.new
# 		@agent.user_agent_alias = 'Mac Firefox'
# 	end

# 	def scrape(uri)
# 		page = @agent.get(uri)
# 	end

# 	def scrape_for_index(letter)
# 		url = "http://www.metacritic.com/browse/movies/title/dvd/#{letter}"
# 		letter_pages = [url]
# 		page = @agent.get(url)
# 		page_count = page.search(".page_num").count
# 		# start the count at page_count minus 1 because of pushing url above
# 		page_count = page_count -1 
# 		index = 1
# 		page_count.times do 
# 			letter_pages.push(url + "?page=#{index}")
# 			index += 1
# 		end
# 		binding.pry
# 		p 'fart'
# 	end

# 	def scrape_for_movies(uri)
# 		movies_uri = []
# 		page = @agent.get(uri)
# 		# gets array of movies
# 		movies = page.search("#mantle_skin .title a")
# 		movies.each_with_index do |movie, i| 
# 			movie_uri = page.search("#mantle_skin .title a")[i].attributes["href"].value
# 			movies_uri.push(movie_uri)
# 		end
# 		p movies_uri
# 	end

# 	def scrape_reviews(movie_uri)
# 		review_collection = []
# 		page = @agent.get(movie_uri)
# 		reviews = page.search("#mantle_skin .pad_top1")
# 		reviews.each_with_index do |review, i|
# 			score = reviews[i].search(".metascore_w")

# 			# Not all author's have their own page so we check
# 			author_uri = reviews[i].search(".author a")
# 			author_uri = author_uri.empty? ? "none" : author_uri[0].attributes["href"].value

# 			#this unless block is necessary because of occasional ads in the body.
# 			# gets info about review and pushes it into review_collection hash
# 			unless score.empty?
# 				score = score.children[0].text
# 				author_name = reviews[i].search(".author").children[0].text
# 				publication_name = reviews[i].search(".source a")[0].text
# 				publication_uri = reviews[0].search(".source a")[0].attributes["href"].value
# 				review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
# 					publication_name: publication_name, publication_uri: publication_uri })
# 			end
# 		end
# 	end
# end

# # TODO for Sunday -
# #scrapers
# #  move to scraper rakefile or actual scrape and refactor some
# #  create rake tasks to scrape all, scrape letter range
# #  create method/class that can scrape http://www.metacritic.com/browse/movies/release-date/theaters/date
# #  create daily cron job to look for new movies in rss feed (XML) maybe using just a api request thing
# #  write tests for scrapers and use vcr gem
# #modify models for columns for review_uri and critic_uri etc also add image thumbnails
# #scrape the reviews (make sure no additions needed for models
# #  setup api for ajax return for queries on movie
# #start frontend
# # create title thing, initially log results in console
# # build css for movie element and have the page display approipriate number based on width
# # after you click on each element for the review have it reload with the appropriate number (checking
# 	#media query again each time in case of resize or phone turn)
# # set up local storage logging for user reviews
# # when user clicks, ajax fires, gets all reviews as api, then javascript loops through each review, 
# # calculates point difference for that critic, updates local storage by critic id with point differential
# # and increments number of matched review and adds a percentage match field
# # log the top 3 with name, percentage, and count of reviews (skews towards an inactive critic who you match with a lot)
# # maybe we need a minimum match
# # do CSS styling for matching bars
# #stretch goals!
# # create critic page where it shows which movies, your score, their score, differential (but i need to store that)
# # create authentication
# # create ability to type in number 1-100
# # TESTS!
# scraper = ScrapeTest.new
# # result = scraper.scrape_for_movies('http://www.metacritic.com/browse/movies/title/dvd')
# result = scraper.scrape_for_index("p")