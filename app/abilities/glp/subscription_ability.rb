# frozen_string_literal: true

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::SubscriptionAbility
  extend ActiveSupport::Concern

  included do
    on(::Subscription) do
      permission(:layer_and_below_full)
        .may(:manage)
        .in_same_layer_or_below
    end
  end
end
