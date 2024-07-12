# frozen_string_literal: true

#  Copyright (c) 2012-2022, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class Group::Kanton < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]

    self.two_factor_authentication_enforced = true
  end

  class Spendenverwalter < Role
    self.permissions = [:financials, :layer_and_below_full, :see_invisible_from_above]

    self.two_factor_authentication_enforced = true
  end

  roles Administrator, Spendenverwalter

  children(Group::KantonDelegierte,
    Group::KantonGewaehlte,
    Group::KantonGeschaeftsstelle,
    Group::KantonVorstand,
    Group::KantonArbeitsgruppe,
    Group::KantonZugeordnete,
    Group::KantonKontakte,
    Group::Bezirk,
    Group::Spender)
end
