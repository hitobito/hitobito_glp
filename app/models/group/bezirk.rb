class Group::Bezirk < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :admin, :contact_data]
  end

  roles Administrator

  children Group::BezirkGewaehlte, Group::BezirkGeschaeftsstelle, Group::BezirkVorstand, Group::BezirkArbeitsgruppe, Group::BezirkZugeordnete, Group::BezirkKontakte, Group::Ortsektion
end
