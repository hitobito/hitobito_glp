module Glp::GroupAbility
  extend ActiveSupport::Concern

  included do
    # on(Group) do
    #   permission(:admin).may(:edit_zipcodes).in_group
    # end
  end

  # def in_group
  #   permission_in_group?(subject.id)
  # end
end
