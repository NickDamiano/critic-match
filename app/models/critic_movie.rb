class CriticMovie < ApplicationRecord
	belongs_to :critic 
	belongs_to :movie

	validates_uniqueness_of :critic_id, :scope => :movie_id
	validates :movie_id, presence: true
	validates :score, presence: true
	validates :critic_id, presence: true
end
