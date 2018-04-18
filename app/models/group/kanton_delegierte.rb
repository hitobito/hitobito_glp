class Group::KantonDelegierte < Group
  class Delegierte < Role
  end

  class Ersatzdelegierte < Role
  end

  roles Delegierte, Ersatzdelegierte
end
