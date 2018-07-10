class Group::RootArbeitsgruppe < ::Group
  children Group::RootArbeitsgruppe

  class Leitung < Role
    self.permissions = [:group_and_below_read, :contact_data]
  end

  class AGMitglied < Role
    self.permissions = [:group_and_below_read]
  end

  roles Leitung, AGMitglied
end
