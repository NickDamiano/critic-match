class Critic < ApplicationRecord
	has_many :critic_movies
	has_many :movies, -> { distinct }, through: :critic_movies
end
