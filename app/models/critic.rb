class Critic < ApplicationRecord
	has_many :critics_movies
	has_many :movies, through: :critics_movies
end
