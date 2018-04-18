class Group::Kanton < Group
  self.layer = true

  children Group::KantonDelegierte, Group::KantonGewaehlte
end
