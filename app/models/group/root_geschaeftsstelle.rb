class Group::RootGeschaeftsstelle < Group
  class Leitung < Role
    self.permissions = [:layer_and_below_full, :admin, :contact_data, :finance, :impersonation]
  end

  class Mitarbeiter < Role
    self.permissions = [:layer_and_below_read, :layer_full, :contact_data]
  end

  class Finanzen < Role
    self.permissions = [:layer_and_below_read, :layer_full, :finance]
  end

  roles Leitung, Mitarbeiter, Finanzen
end
