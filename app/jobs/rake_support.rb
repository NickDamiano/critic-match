class RakeSupport 

  def update_reviews_with_names
    result = CriticMovie.all
    counter = 0
    result.each do | review |
      critic = Critic.find(review.critic_id)
      review.critic_first_name = critic.first_name 
      review.critic_last_name = critic.last_name
      review.publication = critic.publication
      p review.save
      counter +=1
      p counter
    end
  end

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
	      f.close
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
	      f.close
	    end
	end

	def scrape_all_reviews
  		reviews = []
  		scraper = MetacriticScraper.new
    	movies_pages = YAML.load_file('movies_list.yml')
    	# we have to update the yaml as we go because there are thousands upon thousands
    		# of movies and if the scraper fails, we don't want to start from the beginning
  		movies_pages.count.times do
  			movie_list = YAML.load_file('movies_list.yml').reverse
  			movie_page = movie_list.first
      		p "ABOUT TO SCRAPE #{movie_page}"
      		sleep(80)
  			result = scraper.scrape_one_movies_reviews("http://www.metacritic.com#{movie_page}")
      		# Grab first review to pull movie info out and save it if it's not nil
      		if result
      			p "in scrape_all_reviews about to save data"
      			save_data(result, movie_page)
      			# pop off first line (this movie) and save back to yaml
      			movie_list.shift
      			File.open("movies_list.yml", "w+") do |f|
      				f.write(movie_list.to_yaml)
      				f.close
      			p "closing the file, movie_page is #{movie_page}"
      			end
      			# TODO refactor this and above 
      		elsif result.nil?
      			movie_list.shift
      			File.open("movies_list.yml", "w+") do |f|
      				f.write(movie_list.to_yaml)
      				f.close
      			p "closing the file, movie_page is #{movie_page}"
      			end
      		end
  		end
	end

	def save_data(result, movie_page)
		
  		if result == [] || result.nil?
  			File.open("failed_movie_scrapes.yml", "a") do |f|
        			f.write(movie_page.to_yaml)
        			f.close
        			return
        		end
  		end
      # if movie_page == "/movie/la-vida-inmoral-de-la-pareja-ideal"
      #   binding.pry
      #   p 'hi'
      # end
      first = result.first 
  		saver = Saver.new
  		movie = saver.save_movie(first)
      # this line gets rid of existing recent reviews so we don't have duplicates. we scrape recent and maybe 10 people have written reviews
      # a week later 20 have so we don't want those same 10. just start fresh.
      movie.critic_movies.delete_all
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
			reviews = scraper.scrape_one_movies_reviews("http://www.metacritic.com#{movie_uri}")
			save_data(reviews, movie_uri)
		end
	end
end
