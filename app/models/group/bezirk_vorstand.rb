class Group::BezirkVorstand < Group
  class Praesidentln < Role
    self.permissions = [:layer_and_below_read, :group_and_below_full, :contact_data]
  end

  class Vizepraesidentln < Role
    self.permissions = [:group_and_below_full, :contact_data]
  end

  class Geschaeftsleitung < Role
    self.permissions = [:group_and_below_full, :contact_data]
  end

  class Kassier < Role
    self.permissions = [:layer_and_below_read, :contact_data, :finance]
  end

  class Mitglied < Role
    self.permissions = [:group_and_below_read, :contact_data]
  end

  roles Praesidentln, Vizepraesidentln, Geschaeftsleitung, Kassier, Mitglied
end
