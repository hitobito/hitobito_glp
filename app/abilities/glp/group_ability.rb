# frozen_string_literal: true

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::GroupAbility
  extend ActiveSupport::Concern

  included do
    on(Group) do
      # permission(:admin).may(:edit_zipcodes).in_group
      permission(:layer_and_below_full).
        may(:activate_person_add_requests, :deactivate_person_add_requests, :index_service_tokens).
        in_same_layer_or_national_admin
      
      permission(:financials).
        may(:show_donors).
        in_same_layer

    end
  end

  def in_same_layer_or_national_admin
    in_same_layer || (role_type?(Group::Root::Administrator) && in_same_layer_or_below)
  end

  # def in_group
  #   permission_in_group?(subject.id)
  # end
end
