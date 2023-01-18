class AddActiveBooleanToCritic < ActiveRecord::Migration[6.1]
  def change
    add_column :critics, :active?, :boolean
  end
end
