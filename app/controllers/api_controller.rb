class ApiController < ApplicationController

	def get_first_movies
		# gets first group because json scraping takes like 4 seconds. so it gets 10 or so and calls the rest at the same time to put into different variable
		@movies = Movie.where("release_date > ?", 2.years.ago).order(:image_uri).joins(:critic_movies).group('movies.id').having('count(movie_id) > 50').limit(250).to_a
	end
	# probably want to get above 40 or 45 reviews for the movies asked about, then if those are exhausted, get more with lower number of revies
	def get_movies
		@movies = Movie.where("release_date > ?", 3.years.ago).joins(:critic_movies).group('movies.id').having('count(movie_id) > 10').offset(10)limit(250).to_a
		binding.pry
		# TODO it takes too long to load 250 movies so you need to load the first 10 or so, then call to get the rest. 
		@movies = @movies.to_a.map(&:serializable_hash).to_json
		render :json => @movies
	end

	def get_reviews
		reviews_array = []
		movie_ids = params[:id].split(',').map{ |number| number.to_i }
		# I need code here similar to the joins above to get all reviews for these movies at oncek TODO
		# TODO refactor the below to make it one line and one query
		movie_ids.each do | movie_id |
			reviews = Movie.find(movie_id).critic_movies
			reviews_array.push(reviews)
		end
		reviews = reviews_array.to_json
		render :json => reviews
	end

	def get_initial_reviews

		# return api call for just one review
	end
end
