# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class Group::Bezirk < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]

    self.two_factor_authentication_enforced = true
  end

  class Spendenverwalter < Role
    self.permissions = [:financials, :layer_and_below_full, :manage_invisible_people]

    self.two_factor_authentication_enforced = true
  end

  roles Administrator, Spendenverwalter

  children(Group::BezirkGewaehlte,
           Group::BezirkGeschaeftsstelle,
           Group::BezirkVorstand,
           Group::BezirkArbeitsgruppe,
           Group::BezirkZugeordnete,
           Group::BezirkKontakte,
           Group::Ortsektion,
           Group::Spender)
end
