class ApiController < ApplicationController
	# Threshold for number of movie reviews per movie.
	# the problem this is solving is there are a lot of freaking movies made and it's showing movies that I've never seen, which is why i thought about organizing
	# by genre - since showing me horror and romantic movies
	# CUTOFF is the minimum number of movie reviews for it to be considered
	CUTOFF = 10

	# To quickly load landing page, only grabs 5 movies, then ajax calls the rest in the background
	def get_first_movies
		@movies = Movie.where("release_date > ?", 10.years.ago).order('random()').joins(:critic_movies).group('movies.id').having("count(movie_id) > #{CUTOFF}")
		.limit(1).to_a
		@movies.each do | movie | 
			movie.title = movie.title.split.map(&:capitalize).join(' ')
		end
		@movies = @movies.to_a.map(&:serializable_hash).to_json
		render :json => @movies
	end

	# This gets x number random movies released within the last ten years with movie review count greater than 10 reviews
	# Stretch change limit - reduce it and create the system to reduce duplicates on second call since we're pulling random. 
	def get_movies
		@movies = Movie.order("RANDOM()").where("release_date > ?", 10.years.ago).order('random()').joins(:critic_movies).group('movies.id').having("count(movie_id) >= #{CUTOFF}")
		.limit(1000).to_a
		@movies.each do | movie | 
			movie.title = movie.title.split.map(&:capitalize).join(' ')
		end
		@movies = @movies.to_a.map(&:serializable_hash).to_json
		render :json => @movies
	end

	# The api call comes in with params of movie ids separated by comma. This
	# converts them to integers and makes an array of ints, then does an active
	# record query with that array to get movies then capitlizes the titles and returns
	# as json
	def get_movie_batch
		movies_array = []
		movie_ids = params[:id].split(',').map{ |number| number.to_i }
		
		# Get an array of Movie objects from batch ids passed here
		movies = Movie.find(movie_ids)

		# Iterate through each movie and capitalize the title
		movies.each do | movie | 
			movie.title = movie.title.split.map(&:capitalize).join(' ');
		end

		# Convert to json
		movies = movies.to_json
		render :json => movies
	end

	# 
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
