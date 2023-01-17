
class MetacriticScraper

	attr_accessor :agent

	# Agent necessary to prevent forbidden errors from metacritic
	def initialize
		@agent = Mechanize.new
		@agent.user_agent_alias = 'Mac Firefox'
	end

	def scrape_recent_movies
		uri = "http://www.metacritic.com/browse/movies/release-date/theaters/date"
		page = ''
		begin
			page = @agent.get(uri)
		rescue Net::HTTPTooManyRequests, Mechanize::ResponseReadError, Net::HTTPServiceUnavailable
			sleep(61)
			return nil
		end
		movie_links = page.search("a.title")
	end

	def scrape_for_index(letter)
		if letter == '#'
			url = "http://www.metacritic.com/browse/movies/title/dvd"
		else
			url = "http://www.metacritic.com/browse/movies/title/dvd/#{letter}"
		end
		letter_pages = [url]
		page = @agent.get(url)

		# this gets the number of pages of movie reviews for this letter
		page_count = page.search(".last_page .page_num").text.to_i 

		# Needed because page 1 has no number on it, page 2 uri shows page 1
		page_count = page_count -1 
		index = 1
		page_count.times do 
			letter_pages.push(url + "?page=#{index}")
			index += 1
		end
		letter_pages
	end

	def scrape_for_movies_last_365(uri)
		#release_date = page.search(".clamp-details span")
		movies_uri = []
		begin
			page = @agent.get(uri)
		rescue Net::HTTPTooManyRequests, Mechanize::ResponseReadError, Net::HTTPServiceUnavailable
			sleep(61)
			page = @agent.get(uri)
		end
		# gets array of movies
		movies = page.search("a.title")
		movies.each_with_index do |movie, i| 
			# Get the movie uri to scrape
			movie_uri 		= page.search("a.title")[i].attributes["href"].value

			# get the date for the movie to be scraped and compare if for last year
			movie_release 	= page.search(".clamp-details")[i].children[1].children.text

			# if the movie release is to be announced we skip to next iteration
			next if movie_release == "TBA"

			puts movie_release + " is movie_release "
			movie_release_date = movie_release.to_date

			if movie_release_date > 1.year.ago
				movies_uri.push(movie_uri)
			end
		end
		movies_uri
	end

	def scrape_for_movies(uri)
		movies_uri = []
		begin
			page = @agent.get(uri)
		rescue Net::HTTPTooManyRequests, Mechanize::ResponseReadError, Net::HTTPServiceUnavailable
			sleep(61)
			page = @agent.get(uri)
		end
		# gets array of movies
		movies = page.search("a.title")
		movies.each_with_index do |movie, i| 
			movie_uri = page.search("a.title")[i].attributes["href"].value
			movies_uri.push(movie_uri)
		end
		movies_uri
	end

	def scrape_thumbnail(movie_uri_base)
		# thumbnail_link = movie_uri_base[0..-16]
		begin
			sleep(5)
			page = @agent.get(movie_uri_base)
		rescue Net::HTTPTooManyRequests, Mechanize::ResponseReadError, Net::HTTPServiceUnavailable
			sleep(120)
			scrape_thumbnail(movie_uri_base)
		end
		# There are two types of metacritic image links, some pages have a trailer gif thing running in the background and the image is a different class so we handle that
		image_uri = page.search(".summary_img")
		image_uri = image_uri.none? ? page.search(".c-cmsImage")[0].children[1].attributes["src"].text : page.search(".summary_img")[0].attributes["src"].value
	end

	def log_failed(movie_uri)
		File.open("failed_movie_scrapes.yml", "a") do |f|
	      f.write(movie_uri.to_yaml)
	      f.close
	    end
	end

	# scrapes all the reviews from a single movie's URI and returns array of review objects
	# review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
	# publication_name: publication_name, publication_uri: publication_uri, movie_title: movie_title,
	# image_thumbnail: image_thumbnail, release_date: release_date, movie_uri: movie_uri_base, 
	# metacritic_score: metacritic_score })

	def scrape_one_movies_reviews(movie_uri_base)

		p "scraping #{movie_uri_base}"
		review_collection = []
		movie_uri = "#{movie_uri_base}/critic-reviews"
		begin
			page = @agent.get(movie_uri)
		rescue Net::HTTPServiceUnavailable
			p "in review scraper rescue block"
			log_failed(movie_uri)
			sleep(100)
			return nil
		end
		reviews = page.search(".review")

		if reviews.nil? || reviews.empty?
			log_failed(movie_uri_base)
			return nil
		end
		image_thumbnail = scrape_thumbnail(movie_uri_base)

		# iterate through reviews
		reviews.each_with_index do |review, i|
			# returns metacritic score
			score = reviews[i].search(".metascore_w")
			# binding.pry
			# Not all author's have their own page so we check
			author_uri = reviews[i].search(".author a")
			author_uri = author_uri.empty? ? "none" : author_uri[0].attributes["href"].value

			#this unless block is necessary because of occasional ads in the body.
			# gets info about review and pushes it into review_collection hash
			unless score.empty?
				score = score.children[0].text
				p "about to scrape the review for index #{i}"

				# some authors don't have names
				# Get the overall average metascore
				metacritic_score = page.search(".larger").text


				movie_title = page.css("h1").text
				release_date = page.css(".label+ span").text
				# some movies never get a release date on metacritic so scrape first review date
				# 
				if release_date == "TBA"
					release_date = page.css(".review:nth-child(1) .date").text
				end
				author_name = reviews[i].search(".author").empty? ? "none" : reviews[i].search(".author").children[0].text
				# binding.pry
				possible_publication_name = reviews[i].search(".source a")[0].text
				publication_name = possible_publication_name == "" ? reviews[i].search(".source a")[0].children[0].attributes["title"].text : possible_publication_name 
				publication_uri = reviews[i].search(".source a")[0].attributes["href"].text
				review_collection.push({score: score, author_name: author_name, author_uri: author_uri, 
					publication_name: publication_name, publication_uri: publication_uri, movie_title: movie_title,
					image_thumbnail: image_thumbnail, release_date: release_date, movie_uri: movie_uri_base, 
					metacritic_score: metacritic_score })
			end
		end
		review_collection
	end
end

