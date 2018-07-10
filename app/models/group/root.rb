class Group::Root < Group

  self.layer = true

  children Group::RootGeschaeftsstelle, Group::RootVorstand, Group::RootArbeitsgruppe, Group::RootZugeordnete, Group::RootKontakte, Group::RootGewaehlte, Group::Kanton

  # TODO: Leader and member left in for the time being, otherwise single table inheritance crashes the app.
  class Leader < Role
    self.permissions = [:layer_and_below_full, :admin]
  end

  class Member < Role
    self.permissions = [:group_read]
  end

  class Administrator < Role
    self.permissions = [:layer_and_below_full, :admin, :impersonation, :contact_data]
  end

  class Eventverantwortliche < Role
    #TODO: What is the "Events erstellen" permission in the GLP Strukturdokument
    self.permissions = []
  end

  roles Administrator
end
