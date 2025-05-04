Rails.application.routes.draw do
  get "test", to: "test#index"
  get "users/edit_password", to: "users#edit_password", as: :edit_password_users
  patch "users/update_password", to: "users#update_password", as: :update_password_users
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "users/omniauth_callbacks"
  }
  devise_scope :user do
    post "send_password_reset", to: "users/registrations#send_password_reset", as: "send_password_reset"
    get "users/done", to: "users/registrations#done", as: "registration_done"
    get "users/email", to: "users/registrations#email", as: "user_email_registration"
    post "users/email", to: "users/registrations#update_email", as: "user_update_email"
    post "users/skip_email", to: "users/registrations#skip_email_registration", as: "skip_email_registration" 
  end

  namespace :public do
    resources :contacts, only: [ :new, :create ] do
      collection do
        post "confirm"
        get "confirm"
        post "back"
        get "done"
      end
    end
  end
  resources :users, only: [ :show, :edit, :update ] do
    get :check_email, on: :collection
    get :initiate_link_account, on: :collection
    get :link_account, on: :collection
  end
  get "home/index"
  get "tweet/index"
  get "riyoukiyaku/index"
  get "privacypolicy/index"
  get "inquiry/index"
  root "home#index" # 未ログイン時のトップページ
  get "dashboard", to: "dashboard#index", as: "dashboard_index" # ダッシュボードへのルート
  get "/dashboard/data", to: "dashboard#data"
  get "users/show", to: "users#show"
  resources :goals
  get "generate_images/create"
  post "/generate_image", to: "generate_images#create"
  # get "login", to: "sessions#new"
  # /loginにアクセスするとSessionsControllerのnewアクションがよばれる
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
