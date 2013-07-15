ActionController::Routing::Routes.draw do |map|
  map.resources :books, :authors
  map.root :controller => "books", :action => "index"
end
