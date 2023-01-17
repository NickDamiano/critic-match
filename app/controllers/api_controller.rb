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
		.limit(750).to_a
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

	# this is the method hit for the critic page that gets both positive and negative and recommendations
	def get_5_positive_grain
		placeholder_review = CriticMovie.new
		placeholder_review.score = 0 
		top_5 			=	[placeholder_review,placeholder_review,placeholder_review,placeholder_review,
			placeholder_review]
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
			puts movie.id
			critics_movies_hash[movie.id] = {"metacritic_score": movie.metacritic_score, "movie_name": movie.title.titleize}
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
			movie_id 		= 	review.movie_id
			movie_name 		= critics_movies_hash[movie_id][:movie_name]
			critic_score 	= review.score
			metascore 		= critics_movies_hash[movie_id][:metacritic_score]

			# If the review is less than a year ago, it can be evaluated for our top 5 
			if review.date >= 1.year.ago
				# get the lowest value index and compare the review against that
				top_5.sort_by! { |k| k[:score]}
				print(top_5[0])
				if critic_score > top_5[0][:score]
					movie_name 		= critics_movies_hash[movie_id][:movie_name]
					critic_score 	= review.score
					metascore 		= critics_movies_hash[movie_id][:metacritic_score]
					recommend_object = { "movie_name": movie_name, score: critic_score,
						"metascore": metascore }
					top_5[0] = recommend_object
				end
			end	
			# if the score is 0 then that means it was a TBD meaning not enough critic votes and it was converted to 0
			# we do not want this in our array because it will create artificially high or low against the grain scores that are false so
			# we skip this loop iteration and evaluate the next one
			if metascore == 0
				next
			end
			difference	= critic_score - metascore 
			single_movie = {"movie_name": movie_name, "metascore": metascore, "critic_score": critic_score, "difference": difference, }
			positive_grain_array.push(single_movie)
			# {movie_id: 3, critic_score: 34, metascore: 50, difference: -16, }
		end

		# if there were not enough reviews to establish a metacritic score it's set to TBD which translates to 0 when it's scraped into the 
		# 	int type. So if the review is 0 we reject it
		top_5.reject! {| review | review[:score] == 0} 

		# Sort the result, put it into an array and convert to json
		positive_grain_array.sort_by! { |k| k[:difference]}
		negative_grain = positive_grain_array.first(5)
		positive_grain = positive_grain_array.pop(5)
		negative_positive = positive_grain.reverse! + negative_grain.reverse! + top_5
		negative_positive = negative_positive.to_json


		render :json => negative_positive
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
