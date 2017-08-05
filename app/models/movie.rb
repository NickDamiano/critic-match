class Movie < ApplicationRecord
	has_many :critics_movies
	has_many :critics, through: :critics_movies
end
