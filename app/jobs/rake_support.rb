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
	      sleep(10)
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
    	saver = Saver.new
    	movies_pages = saver.get_movie_uris
  		movies_pages.each do | movie_page |
      		p "ABOUT TO SCRAPE #{movie_page}"
  			result = scraper.scrape_reviews("http://www.metacritic.com#{movie_page}")
      		# the above takes back all reviews for one movie. so we should be able to 
        	# grab the first review, get the movie information, and save it to the database
      		first = result.first 
      		if first.nil?
        		binding.pry 
        		p 'uh oh spaghetti-os'
      		end
      		movie = saver.save_movie(first)
      		result.each do | review | 
        		critic = saver.save_critic(review)
        		review = saver.save_review(review, movie, critic)
      		end
	        # iterate through each review, save critic if not already in the database and if in database, get id for critic
	        # save the actual review into the database with movie_id and critic_id
	  		reviews.push(result)
  		end
	end

	def save_movie
	end


end