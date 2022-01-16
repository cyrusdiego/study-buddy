Rails.application.routes.draw do

  resources :contents do
    resources :questions
  end

  # post '/contents/content_id:/questions', to: 'questions#create'
  # delete '/questions/:id', to: 'questions#destroy'

  devise_for :users
  devise_scope :user do
    authenticated :user do
      root 'contents#index', as: :authenticated_root
    end
    unauthenticated :user do
      root 'devise/sessions#new', as: :unauthenticated_root
    end
  end
end
