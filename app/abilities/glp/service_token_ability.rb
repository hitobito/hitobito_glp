# frozen_string_literal: true

#  Copyright (c) 2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::ServiceTokenAbility
  extend ActiveSupport::Concern

  included do
    on(ServiceToken) do
      permission(:layer_and_below_full).may(:manage).in_same_layer_or_national_admin
    end
  end

  def in_same_layer_or_national_admin
    in_same_layer || (role_type?(Group::Root::Administrator) && in_same_layer_or_below)
  end
end
