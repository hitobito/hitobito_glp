module Glp
  module GroupDecorator

    def possible_roles
      super.select do |type|
        can?(:create, parent.roles.build(type: type.sti_name))
      end
    end

  end
end
