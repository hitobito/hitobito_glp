

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
