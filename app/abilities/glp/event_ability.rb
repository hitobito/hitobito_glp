# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::EventAbility
  extend ActiveSupport::Concern

  included do
    on(Event) do
      permission(:layer_and_below_full).
        may(:create, :destroy, :application_market, :qualify, :qualifications_read).
        in_same_layer_or_below
    end
  end
end
