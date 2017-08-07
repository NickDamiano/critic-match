class CriticMovie < ApplicationRecord
	belongs_to :critic 
	belongs_to :movie

	validates_uniqueness_of :critic_id, :scope => :movie_id
end
