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

  roles KantonaleExekutive, KantonaleLegislative, MitgliedKantonalesGerichtObereInstanz, MitgliedKantonalesGerichtErsteInstanz, Staatsanwaltschaft
end
