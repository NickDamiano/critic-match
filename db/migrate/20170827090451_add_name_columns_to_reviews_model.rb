class AddNameColumnsToReviewsModel < ActiveRecord::Migration[5.1]
  def change
  	add_column :critic_movies, :critic_first_name, :string
  	add_column :critic_movies, :critic_last_name, :string
  	add_column :critic_movies, :publication, :string
  end
end
