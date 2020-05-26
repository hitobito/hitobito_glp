# encoding: utf-8

#  Copyright (c) 2012-2020, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::PeopleFilterAbility
  extend ActiveSupport::Concern

  included do
    on(::PeopleFilter) do
      permission(:layer_and_below_full).may(:create, :destroy, :edit, :update).
        in_same_layer_or_below
    end
  end
end
