module Glp
  module Devise::SessionsController
    extend ActiveSupport::Concern
    include Concerns::TwoFactorAuthentication

    included do
      alias_method_chain :create, :two_factor_authentication
    end

    private

    def create_with_two_factor_authentication # rubocop:disable Metrics/MethodLength
      if first_factor_authenticated? && two_factor_authentication_required?
        sign_out
        if too_man_tries?
          flash[:alert] = 'Zu viele falsche 2FA-Codes, bitte versuche es morgen wieder'
          redirect_to '/'
        else
          if send_two_factor_authentication_code
            redirect_to users_two_factor_authentication_confirmation_path(person: { id: person.id })
          else
            flash[:alert] = 'Die Zustellung des 2FA-Codes hat nicht geklappt, bitte kontaktiere das Generalsekretariat'
            redirect_to '/'
          end
        end
      else
        create_without_two_factor_authentication
      end
    end

    def person
      @person ||= ::Person.find_by(email: params[:person][:email])
    end
  end
end
