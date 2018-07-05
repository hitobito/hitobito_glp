class Group::Bezirk < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  roles Administrator

  children Group::BezirkGewaehlte, Group::BezirkGeschaeftsstelle, Group::BezirkVorstand, Group::BezirkArbeitsgruppe, Group::BezirkMitglieder, Group::BezirkKontakte, Group::Ortsektion
end
