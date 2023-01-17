class AddMovieIdNullConstraintToCriticMovie < ActiveRecord::Migration[6.1]
  def change
    change_column_null(:critic_movies, :movie_id, false)
  end
end
