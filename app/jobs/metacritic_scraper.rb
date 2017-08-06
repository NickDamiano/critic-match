require 'mechanize'
require 'pry-byebug'

class MetacriticScraper

	attr_accessor :agent

	def initialize
		@agent = Mechanize.new
		@agent.user_agent_alias = 'Mac Firefox'
	end

	def scrape(uri)
		page = @agent.get(uri)
	end

	def scrape_for_index(letter)
		if letter == '#'
			url = "http://www.metacritic.com/browse/movies/title/dvd"
		else
			url = "http://www.metacritic.com/browse/movies/title/dvd/#{letter}"
		end
		letter_pages = [url]
		page = @agent.get(url)
		page_count = page.search(".page_num").count
		# start the count at page_count minus 1 because of pushing url above
		page_count = page_count -1 
		index = 1
		page_count.times do 
			letter_pages.push(url + "?page=#{index}")
			index += 1
		end
		letter_pages
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
		movies_uri
	end

	def scrape_thumbnail(movie_uri_base)
		page = @agent.get(movie_uri_base)
		image_uri = page.search(".fl.inset_right2 img")[0].attributes["src"].value
	end

	def scrape_reviews(movie_uri_base)
		review_collection = []
		movie_uri = movie_uri_base + "/critic-reviews"
		page = @agent.get(movie_uri)
		reviews = page.search("#mantle_skin .pad_top1")
		image_thumbnail = scrape_thumbnail(movie_uri_base)

		# iterate through reviews
		reviews.each_with_index do |review, i|
			score = reviews[i].search(".metascore_w")
			# Not all author's have their own page so we check
			author_uri = reviews[i].search(".author a")
			author_uri = author_uri.empty? ? "none" : author_uri[0].attributes["href"].value

			#this unless block is necessary because of occasional ads in the body.
			# gets info about review and pushes it into review_collection hash
			unless score.empty?
				score = score.children[0].text
				p "about to scrape the review for index #{i}"
				# some authors don't have names
				metacritic_score = page.search(".larger").text
				movie_title = page.css("h1").text
				release_date = page.css(".label+ span").text
				author_name = reviews[i].search(".author").empty? ? "none" : reviews[i].search(".author").children[0].text
				publication_name = reviews[i].search(".source a")[0].nil? ? "none" : reviews[i].search(".source a")[0].text
				publication_uri = reviews[0].search(".source a")[0].attributes["href"].value
				review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
					publication_name: publication_name, publication_uri: publication_uri, movie_title: movie_title,
					image_thumbnail: image_thumbnail, release_date: release_date, movie_uri: movie_uri_base, 
					metacritic_score: metacritic_score })
			end
		end
		review_collection
	end
end
