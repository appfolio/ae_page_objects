TestApp::Application.routes.draw do
  resources :books, :authors
  root :to => "books#index"
end
