class Movie < ApplicationRecord
	has_many :critic_movies
	has_many :critics, -> { distinct }, through: :critic_movies
end
