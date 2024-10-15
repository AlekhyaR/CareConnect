# frozen_string_literal: true

Rails.application.routes.draw do
  root to: 'messages#index'

  resources :messages, only: %i[create show new index]
  resources :inboxes, only: [:show]

  resources :prescriptions, only: %i[show create new index]

  resources :patients, only: [] do
    get :dashboard

    member do
      post :lost_script
    end
  end

  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'
end
