Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  devise_scope :user do
    post "send_password_reset", to: "users/registrations#send_password_reset", as: "send_password_reset"
    get "users/done", to: "users/registrations#done", as: "registration_done"
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
  resources :users, only: [ :edit, :update ]
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
