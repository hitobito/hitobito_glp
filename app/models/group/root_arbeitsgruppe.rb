class Group::RootArbeitsgruppe < ::Group
  class Leitung < Role
    self.permissions = [:group_and_below_read, :contact_data]
  end

  class Mitglied < Role
    self.permissions = [:group_and_below_read]
  end

  roles Leitung, Mitglied
end
