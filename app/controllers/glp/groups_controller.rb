module Glp
  module GroupsController
    extend ActiveSupport::Concern
    included do
      self.permitted_attrs += [:zipcodes]
    end
  end
end
