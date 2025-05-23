Forum::Engine.routes.draw do
  resources :posts
  root :to => "posts#index"
end
