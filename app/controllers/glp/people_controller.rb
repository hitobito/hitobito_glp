# encoding: utf-8

#  Copyright (c) 2012-2018, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Glp
  module PeopleController
    extend ActiveSupport::Concern
    included do
      self.permitted_attrs += [:title, :preferred_language,
                               :joining_journey, :occupation,
                               :joined_at, :left_at, :website_url, :paperless]
    end
  end
end
