module Glp
  module VariousAbility
    extend ActiveSupport::Concern 

    included do
      on(ExternalForm) do
        class_side(:index).if_admin
        permission(:admin).may(:update).all
      end
    end

  end
end
