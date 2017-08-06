class AddMovieUriToMovies < ActiveRecord::Migration[5.1]
  def change
  	add_column :movies, :movie_uri, :string
  end
end
