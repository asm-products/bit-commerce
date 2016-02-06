Rails.application.routes.draw do
  get 'restore/product_access'

  resources :products do
    resources :purchases, except: :edit
  end

  root 'products#new'
end
