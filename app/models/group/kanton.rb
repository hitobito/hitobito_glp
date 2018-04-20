class Group::Kanton < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :contact_data]
  end

  roles Administrator

  children Group::KantonDelegierte, Group::KantonGewaehlte, Group::KantonGeschaeftsstelle, Group::KantonVorstand, Group::KantonArbeitsgruppe, Group::KantonMitglieder, Group::KantonKontakte
end
