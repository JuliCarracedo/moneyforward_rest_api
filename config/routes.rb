Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  post "/signup", controller: :users, action: :signup
  get "users/:id", controller: :users, action: :show
  patch "users/:id", controller: :users, action: :update
end
