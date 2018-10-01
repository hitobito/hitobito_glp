class MailingListPeopleAttributesController < ApplicationController
  before_action :authorize

  GENDERS = ::Person::GENDERS + ['_nil']
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
