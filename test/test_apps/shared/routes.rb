TestApp::Application.routes.draw do
  if Rails::VERSION::STRING.to_f > 3.0
    mount Forum::Engine, :at => "/forum", :as => "forum_engine"
  end

  resources :books, :authors
  root :to => "books#index"
end
