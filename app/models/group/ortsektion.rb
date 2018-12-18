class Group::Ortsektion < Group
  self.layer = true

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :admin, :contact_data]
  end

  roles Administrator

  children Group::OrtsektionGewaehlte, Group::OrtsektionGeschaeftsstelle, Group::OrtsektionVorstand, Group::OrtsektionArbeitsgruppe, Group::OrtsektionZugeordnete, Group::OrtsektionKontakte
end
