class Group::BezirkMitglieder < Group
  children Group::BezirkMitglieder

  class Mitglied < Role
  end

  class Sympathisant < Role
  end

  class Adressverwaltung < Role
    self.permissions = [:group_and_below_full]
  end

  roles Mitglied, Sympathisant, Adressverwaltung
end
