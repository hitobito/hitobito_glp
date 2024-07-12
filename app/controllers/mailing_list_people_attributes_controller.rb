#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class MailingListPeopleAttributesController < ApplicationController
  before_action :authorize

  GENDERS = ::Person::GENDERS + ["_nil"]
  LANGUAGES = ::Person::PREFERRED_LANGUAGES

  def update
    mailing_list.update!(model_params)
    redirect_to group_mailing_list_subscriptions_path(mailing_list.group, mailing_list)
  end

  private

  def mailing_list
    @mailing_list ||= MailingList.find(params[:mailing_list_id])
  end

  def authorize
    authorize!(:update, mailing_list)
  end

  def model_params
    permitted_params.merge({
      genders: permitted_params[:genders].blank? ?
               nil : permitted_params[:genders].join(","),
      languages: permitted_params[:languages].blank? ?
                 nil : permitted_params[:languages].join(",")
    })
  end

  def permitted_params
    params.permit(:age_start, :age_finish, genders: [], languages: [])
  end
end
