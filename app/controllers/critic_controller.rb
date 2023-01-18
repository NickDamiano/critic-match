class CriticController < ApplicationController
	def critic
		@critic = Critic.find(params[:id])
		@critic_movies = Critic.find(params[:id]).critic_movies.first
	end
end
