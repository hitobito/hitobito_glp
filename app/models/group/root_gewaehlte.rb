class Group::RootGewaehlte < Group
  class Bundesrat < Role
  end

  class Staenderat < Role
  end

  class Nationalrat < Role
  end

  class VollamtBundesrichter < Role
  end

  class NebenamtBundesRichter < Role
  end

  class Bundesverwaltungsrichter < Role
  end

  class Bundespatentrichter < Role
  end

  class Bundesstrafrichter < Role
  end

  roles Bundesrat, Staenderat, Nationalrat, VollamtBundesrichter, NebenamtBundesRichter, Bundesverwaltungsrichter, Bundespatentrichter, Bundesstrafrichter
end
