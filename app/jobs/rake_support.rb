class RakeSupport 
	
	def scrape_all_indices
		index_pages = []
	    scraper = MetacriticScraper.new 

	    index_pages.push(scraper.scrape_for_index('#'))

	    alphabet = ("a".."z").to_a
	    alphabet.each do |letter|
	      result = scraper.scrape_for_index(letter)
	      p "LETTER #{letter} RESULT BELOW!!!!!!!!"
	      index_pages.push(result)
	      # sleep(10)
	    end

	    index_pages.flatten!

	    File.open("index_pages.yml", "w+") do |f|
	      f.write(index_pages.to_yaml)
	    end
	end

	def scrape_all_movies
		scraper = MetacriticScraper.new
		index_pages = YAML.load_file('index_pages.yml')
		movies_pages = []
  		index_pages.each do | index_page |
  			result = scraper.scrape_for_movies(index_page)
  			movies_pages += result
  			p "CURRENT INDEX PAGE IS #{index_page}"
  			sleep(rand(2..3))
  		end

  		File.open("movies_list.yml", "w+") do |f|
	      f.write(movies_pages.to_yaml)
	    end
	end

	def scrape_all_reviews
  		reviews = []
  		scraper = MetacriticScraper.new
    	movies_pages = YAML.load_file('movies_list.yml')
  		movies_pages.each do | movie_page |
      		p "ABOUT TO SCRAPE #{movie_page}"
      		sleep(20)
  			result = scraper.scrape_reviews("http://www.metacritic.com#{movie_page}")
      		# Grab first review to pull movie info out and save it
      		binding.pry
      		unless result.nil?
      			save_data(result, movie_page)
      			# pop off first line (this movie) and save back to yaml
      			movies_pages.shift
      			File.open("movies_list.yml", "w+") do |f|
      				f.write(movies_pages.to_yaml)
      			end
      		end
  		end
	end

	def save_data(result, movie_page)
		first = result.first 
  		if first.nil?
			File.open("failed_movie_scrapes.yml", "a") do |f|
      			f.write(movie_page.to_yaml)
      			return
      		end
  		end

  		saver = DatabaseSaver.new
  		movie = saver.save_movie(first)
  		result.each do | review | 
    		critic = saver.save_critic(review)
    		review = saver.save_review(review, movie, critic)
  		end

	end

	def scrape_recent
		recent_movies = []
		scraper = MetacriticScraper.new
		# import file with recent reviews hash that shows movie-uri and number of reviews
		recent_movie_links = scraper.scrape_recent_movies
		recent_movie_links.each_with_index do | movie_link, i |
			movie_uri = movie_link.attributes["href"].value
			binding.pry
			reviews = scraper.scrape_reviews("http://www.metacritic.com#{movie_uri}")
			save_data(reviews, movie_uri)
		end
	end
end
