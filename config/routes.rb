Gdzlla::Application.routes.draw do

resources :sessions do
end

resources :users, except: [:index] do
  resources :posts, only: [:index]
  match 'setup-twitter', action: 'setup_twitter'
  match 'setup-flickr', action: 'setup_flickr'
end

resources :posts, only: [:show, :create]

post 'go/:version' => 'posts#create'
post 'go' => 'posts#create_v1'

get 'account' => 'users#account'

get 'about' => 'content#about'
get 'help' => 'content#help'
root to: 'content#index'

end
