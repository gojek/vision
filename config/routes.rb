Rails.application.routes.draw do
 

  get 'cobas/new'

  resources :comments
  get 'tags/:tag', to: 'change_requests#index', as: :tag
  get 'change_requests/:id/graceperiod' => 'change_requests#edit_grace_period_notes', :as => 'graceperiod'
  resources :change_requests do
    resources :comments 
    collection do 
          get :deleted # <= this
    end
    collection do
      get :autocomplete_tag_name
    end
    resources :cr_versions, only: [:destroy] do
      member do
        get :diff, to: 'cr_versions#diff'
        patch :rollback, to: 'cr_versions#rollback'
      end
    end
  end
  resources :cr_versions, only: [] do
    member do
      patch :bringback  # <= and that
    end
  end

  get 'signin' => 'pages#signin'

  get 'incident_reports/show'

  get 'incident_reports/index'

  get 'incident_reports/new'

  get 'incident_reports/edit'

  get 'users/show'

  get 'users/index'
  get 'register' => 'users#new'
  post 'users' => 'users#create'
  get 'users/edit/:id' => 'users#edit', :as => 'edit'
  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: "users/omniauth_callbacks" } 
  devise_scope :user do
    get 'sign_in', :to => 'pages#signin', :as => :new_user_session
    get 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end 
  resources :pages
  resources :users
  resources :incident_reports do
      collection do 
          get :deleted # <= this
      end
      resources :versions, only: [:destroy] do
        member do
          get :diff, to: 'versions#diff'
          patch :rollback, to: 'versions#rollback'
        end
      end
  end
resources :versions, only: [] do
    member do
      patch :bringback  # <= and that
    end
  end
  root to: 'pages#index'
  put 'lock_user/:id' => 'users#lock_user', :as => 'lock_user'
  put 'unlock_user/:id' => 'users#unlock_user', :as => 'unlock_user'
  put 'approve/:id' => 'change_requests#approve', :as =>'approve'
  put 'reject/:id' => 'change_requests#reject', :as =>'reject'
  put 'deploy/:id' => 'change_requests#deploy', :as =>'deploy'
  put 'rollback/:id' => 'change_requests#rollback', :as =>'rollback'
  put 'cancel/:id' => 'change_requests#cancel', :as =>'cancel'
  put 'close/:id' => 'change_requests#close', :as => 'close'



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
