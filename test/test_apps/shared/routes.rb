TestApp::Application.routes.draw do
  mount Forum::Engine, :at => "/", :as => "forum_engine"

  resources :books, :authors
  root :to => "books#index"
end
