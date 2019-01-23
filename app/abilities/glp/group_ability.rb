# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


module Glp::GroupAbility
  extend ActiveSupport::Concern

  included do
    # on(Group) do
    #   permission(:admin).may(:edit_zipcodes).in_group
    # end
  end

  # def in_group
  #   permission_in_group?(subject.id)
  # end
end
