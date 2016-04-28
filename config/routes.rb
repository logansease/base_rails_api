SampleApp::Application.routes.draw do  

  #for SEO
  get '/pages/index' => redirect('/pages')
  
  resources :sessions, :only => [:new, :create, :destroy] do 
    collection do
      get :fb_signin
    end
  end
  
  resources :users do
    member do
      get :following, :followers       #makes users/1/following and following_user_path
      post :unlink_provider
    end
    collection do
      post :send_password_recovery
      get :password_recovery
      get :activate
      get :send_activation
      post :create_fb
      get :new_fb
    end
  end

  resources :pages

  resources :tokens, :only => [:create, :destroy] do
    collection do
      put :refresh
      get :logout, to: 'tokens#destroy'
      post :external_auth
      get :web_external_auth
    end
  end

  resources :questions do
    resources :comments
    resources :ratings
  end

  resources :comments do
    resources :ratings
  end

  resources :ratings
  resources :comments
  resources :relationships, :only => [:create, :destroy]

  get '/auth/facebook/callback', :to => 'sessions#fb_signin'

  #helpers to rate questions
  put '/users/:user_id/questions/:question_id/ratings', to: 'ratings#update'
  post '/users/:user_id/questions/:question_id/ratings', to: 'ratings#create'
  delete '/users/:user_id/questions/:question_id/ratings', to: 'ratings#destroy'

  #helpers to follow questions
  post '/questions/:question_id/relationships', to: 'relationships#create'
  delete '/questions/:question_id/relationships', to: 'relationships#destroy'
  get '/questions/:question_id/relationships', to: 'relationships#show'
  get '/users/:user_id/favorites', to: 'questions#favorites'

  root :to => "pages#home" 
  get '/signup', :to => 'users#new'
  get '/contact', :to => 'pages#contact'
  get '/about', :to => 'pages#about'
  get '/signin', :to => 'sessions#new'
  get '/signout', :to => 'sessions#destroy'
  get '/admin', :to => 'pages#admin'
  get '/maintenance', :to => 'pages#maintenance'
  get '/error', :to => 'pages#error'
  get '/sitemap', :to => 'pages#site_map'
  get '/sitemap_xml', :to => 'pages#site_map_xml'

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
