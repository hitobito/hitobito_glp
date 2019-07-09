# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::Kanton < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  roles Administrator

  children(Group::KantonDelegierte,
           Group::KantonGewaehlte,
           Group::KantonGeschaeftsstelle,
           Group::KantonVorstand,
           Group::KantonArbeitsgruppe,
           Group::KantonZugeordnete,
           Group::KantonKontakte,
           Group::Bezirk)
end
