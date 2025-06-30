# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module Glp::Role
  extend ActiveSupport::Concern

  included do
    paper_trail_options[:unless] = proc { |r| r.type.constantize == Group::Spender::Spender }

    def touch_person
      person.paper_trail.save_with_version if type.constantize != Group::Spender::Spender
    end
  end
end
