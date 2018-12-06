# encoding: utf-8

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    match '*path', :controller => 'glp_application', :action => 'handle_options_request', via: :options

    resources :external_forms, only: [:index]
    get 'external_forms/loader', to: "external_forms#loader"

    resources :externally_submitted_people, only: [:create]

    post 'groups/:group_id/mailing_lists/:mailing_list_id/mailing_list_people_attributes',
      to: 'mailing_list_people_attributes#update'

    get 'users/two_factor_authentication_confirmation', to: 'two_factor_authentication#show'
    post 'users/two_factor_authentication_confirmation', to: 'two_factor_authentication#create'
  end

end
