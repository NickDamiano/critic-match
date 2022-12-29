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

	# create the reviews array, pull the critic id and find all reviews (critic_movies), push the reviews into the array,
	# convert it to json and return it
	def get_all_single_critic_movies
		reviews_array = []
		critic_id = params[:id]
		reviews = Critic.find(critic_id).critic_movies
		reviews_array.push(reviews)
		reviews = reviews_array.to_json
		render :json => reviews
	end

	def get_5_positive_grain
		positive_grain_array = []
		critics_movies_hash = {}
		critic_id = params[:id]
		reviews = Critic.find(critic_id).critic_movies

		# create array of movies to pull batch from because it's super expensive to hit the database 1300 times per user request
		movies_array = []
		reviews.each do | review |
			movies_array.push(review.movie_id)
		end

		# Get an array of movie objects that the critic has seen
		critics_movies = Movie.find(movies_array)
		# [{some movie}, {some other movie}]

		# create a hash with movie id as key so we can grab the metacritic score to create our new object
		critics_movies.each do | movie | 
			critics_movies_hash[movie.id] = {"metacritic_score": movie.metacritic_score, "movie_name": movie.title}
		end

		# Create the unsorted result
		# reviews are all the objects showing the critics id, the movies id, and the score of the critic
		# we iterate through each of those reviews
		# we assign the movie's id to a variable
		# we then print object from the critics_movie_hash showing metascore and movie name
		# we then store the metacritic score from that object into a variable named metascore
		# we then store the movie name from that has into a movie name variable
		# we then print the critic score, movie name, metascore, movie id, calculate the difference
		# for critic and meta and then create an object that we will then sort through to get the top or bottom
		# 5 to then return as JSON
		reviews.each do | review |
			movie_id = 	review.movie_id
			metascore 	= critics_movies_hash[movie_id][:metacritic_score]
			movie_name 	= critics_movies_hash[movie_id][:movie_name]
			critic_score = review.score
			difference	= critic_score - metascore 
			single_movie = {"movie_name": movie_name, "metascore": metascore, "critic_score": critic_score, "difference": difference, }
			positive_grain_array.push(single_movie)
			# {movie_id: 3, critic_score: 34, metascore: 50, difference: -16, }
		end

		# Sort the result
		positive_grain_array.sort_by! { |k| k[:difference]}
		negative_grain = positive_grain_array.first(5)
		positive_grain = positive_grain_array.pop(5)
		negative_positive = negative_grain + positive_grain
		negative_positive = negative_positive.to_json
		render :json => negative_positive

		# TODO Monday
		# it's breaking on a nil class for a movie metacriti score saying the movie is nil
		# i just neeed to finish this section here
		# I also need to look into why it's so incredibly slow all o a sudden


			
		# Iterate through array and sort by difference
	end

	def get_5_negative_grain

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
