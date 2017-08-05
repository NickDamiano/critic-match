class CreateCritics < ActiveRecord::Migration[5.1]
  def change
    create_table :critics do |t|
      t.string :first_name
      t.string :last_name
      t.string :publications, array: true, default: []
      t.boolean :active

      t.timestamps
    end
  end
end
