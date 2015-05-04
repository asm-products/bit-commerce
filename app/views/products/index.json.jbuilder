json.array!(@products) do |product|
  json.extract! product, :id, :title, :urls, :price, :email
  json.url product_url(product, format: :json)
end
