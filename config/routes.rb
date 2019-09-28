Rails.application.routes.draw do

  root "tests#index"
  
  devise_for :users
  resources :tests
  resources :signups, only: [:new] do
    collection do
      get 'registration', to: 'signups#registration'
      get 'new', to: 'signups#new'
      get 'sms_confirmation', to: 'signups#sms_confirmation'
      get 'sms', to: 'signups#sms'
      get 'address', to: 'signups#address'
      get 'payment', to: 'signups#payment'
      get 'end', to: 'signups#end'
      get 'signin', to: 'signups#signin'
    end
  end

  resources :items, only: [:index, :new, :show, :edit, :destroy] do
    collection do #member?
      get 'purchase/:id', to: 'items#purchase', as: 'purchase'
    end
  end

  resources :mypages, only: [:index, :edit] do
    collection do
      get "edit_identification", to: "mypages#identification"
      get "logout", to: "mypages#logout"
    end
  end
end