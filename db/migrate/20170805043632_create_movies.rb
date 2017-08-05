class CreateMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.date :release_date
      t.string :genre
      t.integer :metacritic_score
      t.integer :rotten_tomatoes_score

      t.timestamps
    end
  end
end
