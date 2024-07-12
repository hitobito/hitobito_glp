#  Copyright (c) 2012-2018, Grünliberale Partei Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module Glp::Group
  extend ActiveSupport::Concern

  included do
    # self.used_attributes += [:zip_codes]
    # serialize :zip_codes, Array

    root_types Group::Root

    scope :with_zip_codes, -> { where.not(zip_codes: ["", nil]) }
  end
end
