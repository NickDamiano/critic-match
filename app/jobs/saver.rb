class Saver

	# takes a hash
	def save_movie(movie_info)
		p "about to save #{movie_info[:movie_title]}"
		release_date 	 = movie_info[:release_date].to_date
		movie_title 	 = movie_info[:movie_title].downcase
		movie_uri 		 = movie_info[:movie_uri].downcase
		metacritic_score = movie_info[:metacritic_score].downcase
		image_thumbnail  = movie_info[:image_thumbnail].downcase
		movie = Movie.find_by(movie_uri: movie_uri)
		if movie 
			p 'MOVIE ALREADY EXISTS IN DATABASE'
			return movie 
		end
		begin
			movie = Movie.create(title: movie_title, release_date: release_date,
				metacritic_score: metacritic_score, movie_uri: movie_uri,
				image_uri: image_thumbnail )
		rescue ActiveRecord::RecordNotUnique
			p "duplicate record"
		end
		movie
	end

	def save_critic(critic_info)
		p "about to save critic #{critic_info[:author_name]}"
		first_name = critic_info[:author_name].split(" ")[0].downcase
		last_name  = critic_info[:author_name].split(" ")[-1].downcase
		critic_uri = critic_info[:author_uri].downcase
		publication = critic_info[:publication_name].downcase
		publication_uri = critic_info[:publication_uri].downcase
		# critic = Critic. this line gets critic record if it exists and skips below block
		critic = Critic.find_by(first_name: first_name, last_name: last_name, publication: 
			publication)
		if critic 
			p "CRITIC ALREADY EXISTS IN DATABASE"
			return critic 
		end

		begin
			critic = Critic.create(first_name: first_name, last_name: last_name,
				critic_uri: critic_uri, publication: publication,
				publication_uri: publication_uri)
		rescue ActiveRecord::RecordNotUnique
			p "duplicate record"
		end
		critic
	end

	# takes hash below and objects for movie and critic to save with review
	def save_review(review_info, movie_object, critic_object)
		# also have code to prevent duplicate record
		p "about to save the review for #{review_info[:author_name]} review of #{review_info[:movie_title]}  }"
		review = critic_object.critic_movies.create(movie_id: movie_object.id, 
			score: review_info[:score])
		review
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

