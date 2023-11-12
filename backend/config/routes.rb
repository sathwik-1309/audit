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
    get '/send_otp' => 'user#send_otp'
    get '/otp_match' => 'user#otp_match'
    put '/reset_password' => 'user#reset_password'
    get '/settings' => 'user#settings'
  end

  scope :accounts do
    get '/index' => 'account#index'
    get '/index_owed' => 'account#index_owed'
    post '/create' => 'account#create'
    post '/create_owed' => 'account#create_owed'
    put '/:id/update' => 'account#update'
    delete '/:id/delete' => 'account#delete'
    get '/home' => 'account#home'
    get ':id/home_page' => 'account#home_page'
    get ':id/paginate_transactions' => 'account#paginate_transactions'
    get ':id/stats' => 'account#stats'
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
    post '/paid_by_party' => 'transaction#paid_by_party'
    post '/paid_by_you' => 'transaction#paid_by_you'
    post '/settled_by_party' => 'transaction#settled_by_party'
    post '/settled_by_you' => 'transaction#settled_by_you'
    get 'dashboard' => 'transaction#dashboard'
    post '/split' => 'transaction#split'
  end

  scope :sessions do
    post '/sign_in' => 'session#sign_in'
  end

  scope :categories do
    get '/index' => 'category#index'
    post '/create' => 'category#create'
    put '/:id/update' => 'category#update'
    delete '/:id/delete' => 'category#delete'
  end

  scope :sub_categories do
    get '/index' => 'sub_category#index'
    post '/create' => 'sub_category#create'
    delete '/:id/delete' => 'sub_category#delete'
  end

  scope :images do
    get '/profile_pic', to: 'image#profile_pic', as: :uploaded_image
  end

  scope :v1 do
    scope :accounts do
      get '/:id/details' => 'v1/account#details'
      get '/:id/owed_details' => 'v1/account#owed_details'
    end

    scope :categories do
      get '/:id/details' => 'v1/category#details'
      get '/:id/sub_categories' => 'v1/category#sub_categories'
    end

    scope :cards do
      get '/:id/details' => 'v1/card#details'
      put '/:id/pay_bill' => 'v1/card#pay_bill'
    end

    scope :transactions do
      get '' => 'v1/transaction#list'
      get '/analytics' => 'v1/transaction#analytics'
      get '/pie' => 'v1/transaction#pie'
    end

    scope :users do
      get '/home' => 'v1/user#home'
      get '/configs' => 'v1/user#configs'
      put '/update_configs' => 'v1/user#update_configs'
    end
  end
  

end
