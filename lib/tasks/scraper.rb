# module Scrapers
# 	class MetacriticScraper

# 		attr_accessor :agent

# 		# Metacritic blocks with 403 unless alias is set
# 		def initialize
# 			@agent = Mechanize.new
# 			@agent.user_agent_alias = 'Mac Firefox'
# 		end

# 		# Takes letter, scrapes the URIs for that letter (i.e. 5 pages of letter b)
# 			# and returns an array, letter_pages, with the uris for each page
# 		def scrape_indices(letter)
# 			# if statement because the # page has no identifying letter on it
# 			if letter == '#'
# 				url = "http://www.metacritic.com/browse/movies/title/dvd "
# 			else
# 				# Page 1 does not have a page number next to URI - push it into array
# 				url = "http://www.metacritic.com/browse/movies/title/dvd/#{letter}"
# 			end
# 			letter_pages = [url]
# 			page = @agent.get(url)
# 			page_count = page.search(".page_num").count
# 			# start the count at page_count minus 1 because of pushing url above
# 			page_count =- 1
# 			index = 1
# 			page_count.times do 
# 				letter_pages.push(url + "?page=#{index}")
# 				index += 1
# 			end
# 			letter_pages
# 		end
		
# 		# scrapes all links to movie from index page and returns them in an array
# 		def scrape_movie_links(index_page)
# 			movies_uri = []
# 			page = @agent.get(index_page)
# 			# gets array of movies
# 			movies = page.search("#mantle_skin .title a")
# 			movies.each_with_index do |movie, i| 
# 				movie_uri = page.search("#mantle_skin .title a")[i].attributes["href"].value
# 				movies_uri.push(movie_uri)
# 			end
# 			movies_uri
# 		end

# 		# Takes a uri for a group of reviews for a movie. returns an array of hashes
# 			# for each review containing author name/page, publication name/page, score etc
# 		def scrape_reviews(movie_uri)
# 			review_collection = []
# 			page = @agent.get(movie_uri)
# 			reviews = page.search("#mantle_skin .pad_top1")
# 			reviews.each_with_index do |review, i|
# 				score = reviews[i].search(".metascore_w")

# 				# Not all author's have their own page so we check
# 				author_uri = reviews[i].search(".author a")
# 				author_uri = author_uri.empty? ? "none" : author_uri[0].attributes["href"].value

# 				#this unless block is necessary because of occasional ads in the body.
# 				# gets info about review and pushes it into review_collection hash
# 				unless score.empty?
# 					score = score.children[0].text
# 					author_name = reviews[i].search(".author").children[0].text
# 					publication_name = reviews[i].search(".source a")[0].text
# 					publication_uri = reviews[0].search(".source a")[0].attributes["href"].value
# 					review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
# 						publication_name: publication_name, publication_uri: publication_uri })
# 				end
# 			end
# 		end
# 	end
# end