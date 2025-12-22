Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "documents#index"

  resources :documents, only: [:index, :create, :show, :update, :destroy] do
    member do
      get :download
    end
  end

  # Public share access
  get "s/:token", to: "shares#show", as: :share
  post "s/:token/verify", to: "shares#verify", as: :verify_share
  get "s/:token/download", to: "shares#download", as: :download_share
  get "s/:token/preview", to: "shares#preview", as: :preview_share
  post "s/:token/request_access", to: "shares#request_access", as: :request_access_share
end
