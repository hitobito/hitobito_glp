# frozen_string_literal: true

#  Copyright (c) 2012-2023, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

module SortingHat
  FOREIGN_ZIP_CODE = 102
  JGLP_ZIP_CODE = 103

  MONITORING_EMAIL = "schweiz@grunliberale.ch"
  JGLP_EMAIL = "junge@grunliberale.ch"

  ROLES = {
    "Mitglied" => "Zugeordnete",
    "Sympathisant" => "Zugeordnete",
    "Medien_und_dritte" => "Kontakte"
  }.freeze

  def self.locked?(group)
    [FOREIGN_ZIP_CODE, JGLP_ZIP_CODE].any? { |code| code.to_s == group.zip_codes }
  end
end
