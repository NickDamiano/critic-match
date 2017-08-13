Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'home#index'

  get '/api/movies', to: 'api#get_movies'
  get '/api/reviews/:id', to: 'api#get_reviews'
end
