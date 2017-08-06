class Saver

	# takes a hash
	def save_movie(movie_info)
		release_date 	 = movie_info["release_date"].to_date
		movie_title 	 = movie_info["movie_title"]
		movie_uri 		 = movie_info["movie_uri"]
		metacritic_score = movie_info["metacritic_score"]
		movie = Movie.create(title: movie_title, release_date: release_date,
			metacritic_score: metacritic_score, movie_uri: movie_uri )
	end

	def save_critic(critic_info)

	end

	def save_review(review_info)

	end
	
end

=begin 

[{:score=>"70",
  :author_name=>"Rob Staeger",
  :author_uri=>"/critic/rob-staeger?filter=movies",
  :publication_name=>"Village Voice",
  :publication_uri=>"/publication/village-voice?filter=movies",
  :movie_title=>"#Horror",
  :image_thumbnail=>
   "http://static.metacritic.com/images/products/movies/5/c80d84105e9e7757f6d14351ff8913d9.jpg",
   :release_date=>"september 20, 1982"}]
=end