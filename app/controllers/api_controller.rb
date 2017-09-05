class ApiController < ApplicationController
	# Threshold for number of movie reviews per movie
	CUTOFF = 35

	# To quickly load landing page, only grabs 5 movies, then ajax calls the rest in the background
	def get_first_movies
		@movies = Movie.where("release_date > ?", 4.years.ago).order('random()').joins(:critic_movies).group('movies.id').having("count(movie_id) > #{CUTOFF}")
		.limit(6).to_a
		@movies.each do | movie | 
			movie.title = movie.title.split.map(&:capitalize).join(' ')
		end
		@movies = @movies.to_a.map(&:serializable_hash).to_json
		render :json => @movies
	end

	# probably want to get above 40 or 45 reviews for the movies asked about, then if those are exhausted, get more with lower number of revies
	def get_movies
		@movies = Movie.where("release_date > ?", 4.years.ago).order('random()').joins(:critic_movies).group('movies.id').having("count(movie_id) > #{CUTOFF}")
		.limit(500).to_a
		@movies.each do | movie | 
			movie.title = movie.title.split.map(&:capitalize).join(' ')
		end
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
			reviews.each do | review | 
				if review.critic_first_name
					review.critic_first_name.capitalize!
					review.critic_last_name.capitalize!
					review.publication = review.publication.split.map(&:capitalize).join(' ')
				end
			end
			reviews_array.push(reviews)
		end
		reviews = reviews_array.to_json
		render :json => reviews
	end

	def get_initial_reviews

		# return api call for just one review
	end
end
