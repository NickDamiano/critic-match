class AddImageUriToMovie < ActiveRecord::Migration[5.1]
  def change
  	add_column :movies, :image_uri, :strings
  end
end
