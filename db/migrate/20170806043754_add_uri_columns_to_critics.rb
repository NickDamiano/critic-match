class AddUriColumnsToCritics < ActiveRecord::Migration[5.1]
  def change
  	add_column :critics, :critic_uri, :string
  	add_column :critics, :publication_uri, :string
  	remove_column :critics, :publications, :string
  	add_column :critics, :publication, :string
  end
end
