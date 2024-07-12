#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp
  module GroupDecorator
    def possible_roles
      super.select do |type|
        can?(:create, group.roles.build(type: type.sti_name))
      end
    end
  end
end
