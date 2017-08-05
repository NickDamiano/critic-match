class CreateCriticMovies < ActiveRecord::Migration[5.1]
  def change
    create_table :critic_movies do |t|
    	t.belongs_to 	:critics, index: true
    	t.belongs_to 	:movies, index: true
    	t.integer 		:score
    	t.date 			:date
    	t.timestamps
    end
  end
end
