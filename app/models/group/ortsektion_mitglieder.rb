class Group::OrtsektionMitglieder < Group
  children Group::OrtsektionMitglieder

  class Mitglied < Role
  end

  class Sympathisant < Role
  end

  class Adressverwaltung < Role
    self.permissions = [:group_and_below_full]
  end

  roles Mitglied, Sympathisant, Adressverwaltung
end
