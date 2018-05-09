class Group::Root < Group

  self.layer = true

  children Group::RootGeschaeftsstelle, Group::RootVorstand, Group::RootArbeitsgruppe, Group::RootMitglieder, Group::RootKontakte, Group::RootGewaehlte, Group::Kanton, Group::Bezirk, Group::Ortsektion

  # TODO: define default children for each layer/group
  # self.default_children = [Group::RootVorstand]


  # TODO: Leader and member left in for the time being, otherwise single table inheritance crashes the app.
  class Leader < Role
    self.permissions = [:layer_and_below_full, :admin]
  end

  class Member < Role
    self.permissions = [:group_read]
  end

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :admin, :impersonation]
  end

  roles Administrator
end
