#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class Group::OrtsektionArbeitsgruppe < ::Group
  children Group::OrtsektionArbeitsgruppe

  class Leitung < Role
    self.permissions = [:group_and_below_read, :contact_data]
  end

  class Mitglied < Role
    self.permissions = [:group_and_below_read]
  end

  roles Leitung, Mitglied
end
