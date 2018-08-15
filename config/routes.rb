# encoding: utf-8

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    resources :external_forms, only: [:index]
    get 'external_forms/loader', to: "external_forms#loader"

    resources :externally_submitted_people, only: [:create]
  end

end
