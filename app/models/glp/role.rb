# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::Role
  extend ActiveSupport::Concern

  included do
    def touch_person
      person.touch if self.type.constantize != Group::Spender::Spender
    end
  end
end
