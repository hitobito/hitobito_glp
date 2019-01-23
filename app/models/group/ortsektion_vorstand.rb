# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::OrtsektionVorstand < Group
  class Praesidentln < Role
    self.permissions = [:layer_and_below_read, :group_and_below_full, :contact_data]
  end

  class Vizepraesidentln < Role
    self.permissions = [:group_and_below_full, :contact_data]
  end

  class Geschaeftsleitung < Role
    self.permissions = [:group_and_below_full, :contact_data]
  end

  class Kassier < Role
    self.permissions = [:layer_and_below_read, :contact_data, :finance]
  end

  class Mitglied < Role
    self.permissions = [:group_and_below_read, :contact_data]
  end

  roles Praesidentln, Vizepraesidentln, Geschaeftsleitung, Kassier, Mitglied
end
