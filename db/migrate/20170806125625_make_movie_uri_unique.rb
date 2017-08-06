class MakeMovieUriUnique < ActiveRecord::Migration[5.1]
  def change
  	add_index :movies, :movie_uri, unique: true
  end
end
