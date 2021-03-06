Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'cobas/new'

  resources :comments

  patch 'change_requests/:id/after_deploy_update', to: 'change_requests#after_deploy_update', as: :after_deploy_update

  get 'change_requests/tags/:tag', to: 'change_requests#index', as: :tag
  get 'incident_reports/tags/:tag', to: 'incident_reports#index', as: :incident_report_tag
  get 'change_requests/:id/graceperiod' => 'change_requests#edit_grace_period_notes', :as => :graceperiod
  get 'change_requests/:id/implementation' => 'change_requests#edit_implementation_notes', :as => :implementation_notes
  post 'change_requests/:id/deploy' => 'change_request_statuses#deploy', :as => 'deploy'
  post 'change_requests/:id/rollback' => 'change_request_statuses#rollback', :as =>'rollback'
  post 'change_requests/:id/cancel' => 'change_request_statuses#cancel', :as =>'cancel'
  post 'change_requests/:id/close' => 'change_request_statuses#close', :as => 'close'
  post 'change_requests/:id/fail' => 'change_request_statuses#fail', :as => 'fail'
  post 'change_requests/:id/submit' => 'change_request_statuses#submit', :as => 'submit'

  resources :change_requests do

    resources :comments do
      post :hide, to: 'comments#hide_unhide'
    end
    collection do
          get :deleted # <= this
          get :export_csv
          get :search #=> 'change_requests#search', :as => 'search'
          get :jiraize
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

  get 'incident_reports_by_source' => 'incident_reports#incident_reports_by_source'
  get 'change_requests_by_success_rate' => 'change_requests#change_requests_by_success_rate'
  get 'incident_reports_by_recovered_resolved_duration' => 'incident_reports#incident_reports_by_recovered_resolved_duration'
  get 'incident_reports_number' => 'incident_reports#incident_reports_number'
  get 'incident_reports_internal_external' => 'incident_reports#incident_reports_internal_external'
  get 'total_incident_per_level' => 'incident_reports#total_incident_per_level'
  get 'average_recovery_time_incident' => 'incident_reports#average_recovery_time_incident'
  get 'signin' => 'pages#signin'
  get 'blank' => 'pages#blank'


  get 'incident_reports/show'

  get 'incident_reports/index'

  get 'incident_reports/new'

  get 'incident_reports/edit'

  get 'users/show'

  get 'users/index'
  get 'register' => 'users#new', as: 'register'
  post 'register' => 'users#create', as: 'post_register'
  get 'users/edit/:id' => 'users#edit', :as => 'edit'
  get 'change_requests/:id/print' => 'change_requests#print', :as => 'print'

  devise_for :users, skip: [:sessions], controllers: { omniauth_callbacks: "users/omniauth_callbacks" }
  devise_scope :user do
    get 'sign_in', :to => 'pages#signin', :as => :new_user_session
    delete 'sign_out', :to => 'devise/sessions#destroy', :as => :destroy_user_session
  end
  resources :pages
  resources :users

  resources :incident_reports do

    collection do
      get :deleted
      get :search
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
  put 'approve_user/:id' => 'users#approve_user', :as => 'approve_user'
  put 'reject_user/:id' => 'users#reject_user', :as => 'reject_user'
  post 'approve/:id' => 'change_requests#approve', :as =>'approve'
  post 'reject/:id' => 'change_requests#reject', :as =>'reject'
  get 'notifications/clear_notifications' => 'notifications#clear_notifications'
  get 'duplicate/:id' => 'change_requests#duplicate', :as => 'duplicate'
  get 'notifications/index' => 'notifications#index'
  get 'create_hotfix/:id' => 'change_requests#create_hotfix', :as => 'create_hotfix'

  resources :access_requests do

    resources :access_request_comments do
      post :hide, to: 'access_request_comments#hide_unhide'
    end

    member do
      post :cancel
      post :close
      post :approve
      post :reject
    end

    collection do
      get :search
      post :import_from_csv
    end
  end


  namespace :api do
    post 'change_requests/action'
  end
end
