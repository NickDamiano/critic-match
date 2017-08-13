class ApiController < ApplicationController

	def get_movies
		@movies = Movie.where("release_date > ?", 3.years.ago).joins(:critic_movies).group('movies.id').having('count(movie_id) > 10').limit(250).to_a
		@movies = @movies.to_a.map(&:serializable_hash).to_json
		render :json => @movies
	end

	def get_reviews
		# movie is roll bounce
		# so it's like /reviews/1320
		# and it does Movie.find_by(title: "roll bounce").critic_movies
		movie_id = params[:id].to_i
		reviews = Movie.find(movie_id).critic_movies.to_a
		reviews = reviews.to_a.map(&:serializable_hash).to_json
		render :json => reviews
	end

	def get_review
		review_id = params[:id].to_i
		# return api call for just one review
	end

	def get_select_reiews
		# movie_ids separated by comma, import them
		# return {movie_id: 1, reviews: [{some movies}]} 
		
	end
end
