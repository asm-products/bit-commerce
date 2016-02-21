Rails.application.routes.draw do
  get 'restore/product_access'

  resources :products do
    resources :purchases, except: :edit
  end

  root 'pages#show'
end
