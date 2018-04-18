class Group::Bezirk < Group
  self.layer = true

  class Regierungsstatthalter < Role
  end

  roles Regierungsstatthalter
end
