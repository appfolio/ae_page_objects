ActionController::Routing::Routes.draw do |map|
  map.view_book 'book_viewer', :controller => 'books', :action => 'show'

  map.resources :books, :authors
  map.root :controller => "books", :action => "index"
end
