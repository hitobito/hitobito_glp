class ExternalPeopleFormSubmissionsController < ApplicationController
  skip_authorization_check

  def create
    pry
    puts "HELLO"
    group = Group.find_by_zip_code(zip_code: external_people_form_submission_params[:zip_code])
    Person.create!(email: external_people_form_submission_params[:email],
                   groups: [group],
                   type: "Group::RootVorstand::Praesidentln",
                   roles: [external_people_form_submission_params[:role]])
  end

  private

  def external_people_form_submission_params
    params.require(:external_people_form_submission).permit(:email, :zip_code, :role)
  end
end
