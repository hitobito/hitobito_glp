# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


Rails.application.routes.draw do

  extend LanguageRouteScope

  language_scope do
    get 'external_forms', to: "external_forms#index"
    get 'external_forms/test', to: "external_forms#test"
    get 'external_forms/loader', to: "external_forms#loader"

    resources :externally_submitted_people, only: [:create]

    post 'groups/:group_id/mailing_lists/:mailing_list_id/mailing_list_people_attributes',
      to: 'mailing_list_people_attributes#update'
  end

end
