class Group::OrtsektionZugeordnete < Group
  children Group::OrtsektionZugeordnete

  class Mitglied < Role
  end

  class Sympathisant < Role
  end

  class Adressverwaltung < Role
    self.permissions = [:group_and_below_full]
  end

  roles Mitglied, Sympathisant, Adressverwaltung
end
