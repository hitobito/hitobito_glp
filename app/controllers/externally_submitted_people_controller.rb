class ExternallySubmittedPeopleController < ApplicationController
  skip_authorization_check

  respond_to :js

  def devise_controller?
    true
  end

  def create
    ActiveRecord::Base.transaction do
      person = Person.create(first_name: externally_submitted_person_params[:first_name],
                             last_name: externally_submitted_person_params[:last_name],
                             email: externally_submitted_person_params[:email])
      # person.roles.create(type: "Group::RootZugeordnete::#{externally_submitted_person_params[:role].capitalize}", group: group)
      Role.create!(type: "Group::RootZugeordnete::#{externally_submitted_person_params[:role].capitalize}", person: person, group: group)
    end

  end

  private

  def group
    Group.find_by_zip_code(externally_submitted_person_params[:zip_code])
  end

  def externally_submitted_person_params
    params.require(:externally_submitted_person).permit(:email, :zip_code, :role, :first_name, :last_name)
  end

end
