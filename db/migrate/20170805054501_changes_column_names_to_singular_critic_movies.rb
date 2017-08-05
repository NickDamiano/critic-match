class ChangesColumnNamesToSingularCriticMovies < ActiveRecord::Migration[5.1]
  def change
  	rename_column :critic_movies, :critics_id, :critic_id
  	rename_column :critic_movies, :movies_id, :movie_id
  end
end
