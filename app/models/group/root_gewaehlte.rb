#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

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

  roles(Bundesrat,
    Staenderat,
    Nationalrat,
    VollamtBundesrichter,
    NebenamtBundesRichter,
    Bundesverwaltungsrichter,
    Bundespatentrichter,
    Bundesstrafrichter)
end
