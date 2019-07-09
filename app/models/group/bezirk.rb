# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::Bezirk < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  roles Administrator

  children(Group::BezirkGewaehlte,
           Group::BezirkGeschaeftsstelle,
           Group::BezirkVorstand,
           Group::BezirkArbeitsgruppe,
           Group::BezirkZugeordnete,
           Group::BezirkKontakte,
           Group::Ortsektion)
end
