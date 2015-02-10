json.array!(@authors) do |author|
  json.extract! author, :id
  json.url author_url(author, format: :json)
end
