class Group::BezirkKontakte < Group
  children Group::BezirkKontakte

  class Adressverwaltung < Role
    self.permissions = [:group_and_below_full]
  end
  class Kontakt < Role
  end

  roles Adressverwaltung, Kontakt
end
