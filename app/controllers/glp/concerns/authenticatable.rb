# frozen_string_literal: true

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp
  module Concerns::Authenticatable
    extend ActiveSupport::Concern

    def authenticate_person!(*args)
      if pending_two_factor_auth? && !two_factor_auth_form?
        abort_two_factor_auth!
      end

      super
    end

    private

    def two_factor_auth_form?
      controller_name.eql?(:two_factor_authentication_controller)
    end

    def pending_two_factor_auth?
      session[:two_fa_person_id].present?
    end

    def abort_two_factor_auth!
      reset_session
      redirect_to new_person_session_path 
    end

  end
end
