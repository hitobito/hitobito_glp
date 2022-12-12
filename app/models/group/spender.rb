# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::Spender < Group

  class Spender < Role
    # Skips paper_trail for this role type
    has_paper_trail on: []

    self.permissions = []

    self.visible_from_above = false
  end

  roles Spender
end
