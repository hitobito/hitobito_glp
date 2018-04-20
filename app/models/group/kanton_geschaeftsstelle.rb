class Group::KantonGeschaeftsstelle < Group
  class Leitung < Role
    self.permissions = [:layer_and_below_full, :contact_data, :finance]
  end

  class Mitarbeiter < Role
    self.permissions = [:layer_and_below_read, :layer_full, :contact_data]
  end

  roles Leitung, Mitarbeiter
end
