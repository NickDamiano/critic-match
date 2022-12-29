Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'

  get '/api/movies', to: 'api#get_movies'
  get '/api/movies/first-movies', to: 'api#get_first_movies'
  get '/api/movies/:id', to: 'api#get_movie_batch'
  get '/api/reviews/initial', to: 'api#get_initial_reviews'
  get '/api/reviews/:id', to: 'api#get_reviews'
  get '/api/critic-reviews/:id', to: 'api#get_all_single_critic_movies'
  get '/api/grain-positive/:id', to: 'api#get_5_positive_grain'
  get '/api/grain-negative/:id', to: 'api#get_5_negative_grain'
  get '/critic/:id', to: 'critic#critic'
end
