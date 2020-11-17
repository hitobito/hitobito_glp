# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class TwoFactorAuthenticationController < ApplicationController
  skip_authorization_check
  skip_before_action :authenticate_person!
  before_action :redirect_unless_2fa_pending

  include TwoFactorAuthentication

  def show
    @person = two_fa_person
  end

  def create
    if two_factor_authenticate(second_factor_code)
      sign_in two_fa_person
      session.delete(:two_fa_person_id)
      redirect_to '/'
    else
      flash[:alert] = '2FA-Code falsch oder abgelaufen, bitte versuche es erneut'
      redirect_to users_two_factor_authentication_confirmation_path
    end
  end

  private

  def two_fa_person
    @two_fa_person ||= Person.find(session[:two_fa_person_id])
  end

  def second_factor_code
    params[:person][:second_factor_code]
  end

  def redirect_unless_2fa_pending
    redirect_to root_path unless pending_two_factor_auth?
  end

end
