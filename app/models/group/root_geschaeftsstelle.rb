# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::RootGeschaeftsstelle < Group
  class Leitung < Role
    self.permissions = [:layer_and_below_full, :admin, :contact_data]
  end

  class Mitarbeiter < Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  class Finanzen < Role
    self.permissions = [:layer_and_below_read, :layer_full, :finance, :contact_data]
  end

  roles Leitung, Mitarbeiter, Finanzen
end
