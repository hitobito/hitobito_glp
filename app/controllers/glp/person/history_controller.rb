# frozen_string_literal: true

#  Copyright (c) 2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp
  module Person::HistoryController
    extend ActiveSupport::Concern

    def fetch_roles
      return super if donor_visible?

      super.reject { |r| r.type == ::Group::Spender::Spender.sti_name }
    end

    private

    def donor_visible?
      ::PersonReadables.new(current_user, group).donor_visible?
    end
  end
end
