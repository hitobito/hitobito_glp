#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.

class Group::KantonGewaehlte < Group
  class KantonaleExekutive < Role
  end

  class KantonaleLegislative < Role
  end

  class MitgliedKantonalesGerichtErsteInstanz < Role
  end

  class MitgliedKantonalesGerichtObereInstanz < Role
  end

  class Staatsanwaltschaft < Role
  end

  class ParlamentarischeGeschaeftsfuehrung < Role
  end

  roles(KantonaleExekutive,
    KantonaleLegislative,
    MitgliedKantonalesGerichtObereInstanz,
    MitgliedKantonalesGerichtErsteInstanz,
    Staatsanwaltschaft,
    ParlamentarischeGeschaeftsfuehrung)
end
