class Movie < ApplicationRecord
	has_many :critic_movies
	has_many :critics, through: :critic_movies
end
