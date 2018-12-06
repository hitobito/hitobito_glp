class TwoFactorAuthenticationController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_person!

  include Concerns::TwoFactorAuthentication

  def show
    @person = person
  end

  def create
    if two_factor_authenticate(second_factor_code)
      sign_in person
      redirect_to '/'
    else
      flash[:alert] = '2FA-Code falsch oder abgelaufen, bitte versuche es erneut'
      redirect_to users_two_factor_authentication_confirmation_path(person: { id: person.id })
    end
  end

  private

  def person
    Person.find(params[:person][:id])
  end

  def second_factor_code
    params[:person][:second_factor_code]
  end

end
