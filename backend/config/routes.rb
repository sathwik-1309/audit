require 'sidekiq/web'
Rails.application.routes.draw do
  mount ActionCable.server => '/cable'
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  scope :users do
    get '/index' => 'user#index'
    get '/check' => 'user#check'
    post '/create' => 'user#create'
    put '/update' => 'user#update'
  end

  scope :accounts do
    get '/index' => 'account#index'
    post '/create' => 'account#create'
    post '/create_owed' => 'account#create_owed'
    put '/:id/update' => 'account#update'
    delete '/:id/delete' => 'account#delete'
    get '/home' => 'account#home'
  end

  scope :mops do
    get '/index' => 'mop#index'
    post '/create' => 'mop#create'
    put '/:id/update' => 'mop#update'
    delete '/:id/delete' => 'mop#delete'
  end

  scope :cards do
    get '/index' => 'card#index'
    post '/create' => 'card#create'
    put '/:id/update' => 'card#update'
    delete '/:id/delete' => 'card#delete'
  end

  scope :transactions do
    get '/index' => 'transaction#index'
    put '/:id/update' => 'transaction#update'
    delete '/:id/delete' => 'transaction#delete'
    post '/debit' => 'transaction#debit'
    post '/credit' => 'transaction#credit'
    get 'dashboard' => 'transaction#dashboard'
  end

  scope :sessions do
    post '/sign_in' => 'session#sign_in'
  end

end
