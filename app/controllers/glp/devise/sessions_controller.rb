# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp
  module Devise::SessionsController
    extend ActiveSupport::Concern
    include TwoFactorAuthentication

    attr_reader :two_fa_person

    def create # rubocop:disable Metrics/MethodLength
      @two_fa_person = current_person
      if first_factor_authenticated? && two_factor_authentication_required?
        sign_out
        session[:two_fa_person_id] = @two_fa_person.id

        if too_many_tries?
          reset_session
          flash[:alert] = 'Zu viele falsche 2FA-Codes, bitte versuche es morgen wieder'
          redirect_to '/'
        else
          if send_two_factor_authentication_code
            redirect_to users_two_factor_authentication_confirmation_path
          else
            reset_session
            flash[:alert] = 'Die Zustellung des 2FA-Codes hat nicht geklappt, ' \
              'bitte kontaktiere das Generalsekretariat'
            redirect_to '/'
          end
        end
      else
        super
      end
    end
  end
end
