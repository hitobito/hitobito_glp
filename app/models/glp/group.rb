# encoding: utf-8

module Glp::Group
  extend ActiveSupport::Concern

  included do
    # self.used_attributes += [:zip_codes]
    # serialize :zip_codes, Array


    root_types Group::Root
  end

end
