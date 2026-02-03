Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  namespace :admin do
    resources :users do
      collection do
        get :import
        post :import, action: :import_create
      end
    end
    resources :texts
  end

  resources :groups do
    resources :members, controller: 'group_members', only: [:create, :destroy]
  end

  resources :assignments, only: [:index, :new, :create, :destroy]

  resources :tests, only: [:index, :new, :create, :destroy] do
    member do
      get :take
      post :submit
      get :result
    end
    resources :submissions, only: [:index, :show, :update]
  end

  namespace :learning do
    resources :texts, only: [:index, :show] do
      member do
        get :practice
        post :save_progress
        get :self_test
        post :check_self_test
      end
    end
    resources :progress, only: [:index, :show]
  end

  namespace :analytics do
    resources :groups, only: [:index, :show] do
      member do
        get "members/:member_id", action: :member, as: :member
      end
    end
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "dashboard#index"
end
