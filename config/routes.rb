Rails.application.routes.draw do


  get 'cobas/new'

  resources :comments

  get 'change_requests/tags/:tag', to: 'change_requests#index', as: :tag
  get 'incident_reports/tags/:tag', to: 'incident_reports#index', as: :incident_report_tag
  get 'change_requests/:id/graceperiod' => 'change_requests#edit_grace_period_notes', :as => 'graceperiod'
  get 'change_requests/:id/implementation' => 'change_requests#edit_implementation_notes', :as => 'implementation_notes'
  post 'change_requests/:id/deploy' => 'change_request_statuses#deploy', :as => 'deploy'
  post 'change_requests/:id/rollback' => 'change_request_statuses#rollback', :as =>'rollback'
  post 'change_requests/:id/cancel' => 'change_request_statuses#cancel', :as =>'cancel'
  post 'change_requests/:id/close' => 'change_request_statuses#close', :as => 'close'
  post 'change_requests/:id/final_reject' => 'change_request_statuses#final_reject', :as => 'final_reject'
  post 'change_requests/:id/schedule' => 'change_request_statuses#schedule', :as => 'schedule'
  post 'change_requests/:id/submit' => 'change_request_statuses#submit', :as => 'submit'
  resources :change_requests do

    resources :comments
    collection do
          get :deleted # <= this
    end
    #collection do
      #get :autocomplete_tag_name
    #end
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
  resources :cabs do
    get :get_cabs, on: :collection
  end
  get 'cabs/:id/get_change_requests' => 'cabs#get_change_requests'
  get 'incident_reports_by_source' => 'incident_reports#incident_reports_by_source'
  get 'change_requests_by_success_rate' => 'change_requests#change_requests_by_success_rate'
  get 'incident_reports_by_recovered_resolved_duration' => 'incident_reports#incident_reports_by_recovered_resolved_duration'
  get 'incident_reports_number' => 'incident_reports#incident_reports_number'
  get 'signin' => 'pages#signin'
  get 'blank' => 'pages#blank'


  get 'incident_reports/show'

  get 'incident_reports/index'

  get 'incident_reports/new'

  get 'incident_reports/edit'


  get 'users/show'
  post 'cabs/:id'=> 'cabs#update_change_requests', :as => 'update_cr'

  get 'users/index'
  get 'register' => 'users#new'
  post 'users' => 'users#create'
  get 'users/edit/:id' => 'users#edit', :as => 'edit'
  get 'change_requests/:id/print' => 'change_requests#print', :as => 'print'
  get 'users/clear_notifications' => 'users#clear_notifications'
  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'pages#signin', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
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
  post 'approve/:id' => 'change_requests#approve', :as =>'approve'
  post 'reject/:id' => 'change_requests#reject', :as =>'reject'




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
