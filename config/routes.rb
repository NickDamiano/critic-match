Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'

  get '/api/movies', to: 'api#get_movies'
  get '/api/movies/first-movies', to: 'api#get_first_movies'
  get '/api/reviews/initial', to: 'api#get_initial_reviews'
  get '/api/reviews/:id', to: 'api#get_reviews'
  get '/critic/:id', to: 'home#critic'
end
