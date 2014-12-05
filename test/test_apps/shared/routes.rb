TestApp::Application.routes.draw do
  if Rails::VERSION::STRING.to_f > 3.0
    mount Forum::Engine, :at => "/", :as => "forum_engine"
  end

  get 'book_viewer' => 'books#show', :as => :view_book

  resources :books, :authors

  root :to => "books#index"
end
