require 'pry-byebug'
class Saver

	# takes a hash
	def save_movie(movie_info)
		binding.pry
		p "about to save #{movie_info[:movie_title]}"
		release_date 	 = movie_info[:release_date].to_date
		movie_title 	 = movie_info[:movie_title]
		movie_uri 		 = movie_info[:movie_uri]
		metacritic_score = movie_info[:metacritic_score]
		image_thumbnail  = movie_info[:image_thumbnail]
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
		first_name = critic_info[:author_name].split(" ")[0]
		last_name  = critic_info[:author_name].split(" ")[-1]
		critic_uri = critic_info[:author_uri]
		publication = critic_info[:publication_name]
		publication_uri = critic_info[:publication_uri]
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
		p "about to save the review for #{review_info[:author_name]} review of #{review_info[:movie_title]}  }"
		review = critic.critic_movies.create(movie_id: movie_object.id, 
			score: review_info[:score], movie_uri: movie_uri)
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

