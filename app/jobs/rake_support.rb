

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

  def update_reviews_with_dates
    result = CriticMovie.all
    counter = 0
    result.each do | review |
      review.date = review.movie.release_date
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

	# Create instance of MetacriticScraper, load the index pages, iterate through the index pages
	# scrape the movies urls, push the links from that index page into movies_page array, after scraping
	# write to movies_list.yml all movie pages to scrape link. 
	def scrape_all_movies
		scraper = MetacriticScraper.new
		index_pages = YAML.load_file('index_pages.yml')
		movies_pages = []
  		index_pages.each do | index_page |
  			result = scraper.scrape_for_movies(index_page)
  			movies_pages += result
  			p "CURRENT INDEX PAGE IS #{index_page}"

  			# because we get blocked scraping - we write the movies list each time
  			File.open("movies_list.yml", "w+") do |f|
	      	f.write(movies_pages.to_yaml)
	      	f.close
	    	end

  			sleep(rand(2..3))
  		end
	end

	def scrape_last_365
		scraper = MetacriticScraper.new
		index_pages = YAML.load_file('index_pages.yml')
		movies_pages = []
  		index_pages.each do | index_page |
  			result = scraper.scrape_for_movies_last_365(index_page)
  			movies_pages += result
  			p "CURRENT INDEX PAGE IS #{index_page}"

  			# because we get blocked scraping - we write the movies list each time
  			File.open("movies_list.yml", "w+") do |f|
	      	f.write(movies_pages.to_yaml)
	      	f.close
	    	end

  			sleep(rand(2..3))
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
      		sleep(rand(10..20))
  			result = scraper.scrape_one_movies_reviews("http://www.metacritic.com#{movie_page}")

      		# Grab first review to pull movie info out and save it if it's not nil. If it's nil we remove the movie
      		# and update the movies yaml file
      		if result
      			p "in scrape_all_reviews about to save data"
      			save_data(result, movie_page)
      			# pop off first line (this movie) and save back to yaml so we don't duplicate it again later
      			movie_list.shift
      			File.open("movies_list.yml", "w+") do |f|
      				f.write(movie_list.to_yaml)
      				f.close
      			p "closing the file, movie_page is #{movie_page}"
      			end
      			# 
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

	# TODO fix this bug that is making movie scrapes create a CriticMovie record where the movie_id is broken 
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

	def save_data(result, movie_page)
		
  		if result == [] || result.nil?
  			File.open("failed_movie_scrapes.yml", "a") do |f|
    			f.write(movie_page.to_yaml)
    			f.close
    			return
    		end
  		end
     
      first = result.first 
  		saver = Saver.new
  		movie_link = first[:movie_uri]
  		movie = Movie.where(movie_uri: movie_link )
  		# if the movie exists we delete the reviews and the movie to rescrape it. used when scraping recent movies
  		# that have new reviews added over several days or rescraping periods. Else we save the movie and the associated reviews
  		if movie.any?
  			movie[0].critic_movies.destroy_all
  			movie[0].destroy
  		end
  		movie = saver.save_movie(first)
  		result.each do | review | 
    		critic = saver.save_critic(review)
    		review = saver.save_review(review, movie, critic)
    		puts review.movie_id
    		puts "movie id above"
			end
  		

	end

end
