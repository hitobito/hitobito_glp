class Group::OrtsektionKontakte < Group
  children Group::OrtsektionKontakte

  class Adressverwaltung < Role
    self.permissions = [:group_and_below_full]
  end
  class Kontakt < Role
  end

  roles Adressverwaltung, Kontakt
end
