MoodSwings::Application.routes.draw do
  resources :answer_sets, only: [:index, :new, :create], path: :swingings
  resources :cohorts
  resources :metrics

  devise_for :users, controllers: { registrations: "registrations", invitations: "invitations" }

  root to: 'answer_sets#index', constraints: lambda { |request| request.env['warden'] && request.env['warden'].user && request.env['warden'].user.admin? }
  root to: 'home#index'

end
