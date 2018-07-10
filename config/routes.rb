# encoding: utf-8

Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    resources :external_forms
    resources :external_people_form_submissions, only: [:create]
  end

end
