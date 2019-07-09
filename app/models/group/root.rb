# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::Root < Group

  self.layer = true

  children Group::RootGeschaeftsstelle,
           Group::RootVorstand,
           Group::RootArbeitsgruppe,
           Group::RootZugeordnete,
           Group::RootKontakte,
           Group::RootGewaehlte,
           Group::Kanton

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :admin, :impersonation, :contact_data]
  end

  class Eventverantwortliche < Role
    #TODO: What is the "Events erstellen" permission in the GLP Strukturdokument
    self.permissions = []
  end

  roles Administrator
end
