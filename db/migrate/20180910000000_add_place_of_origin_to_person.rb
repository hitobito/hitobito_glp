# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class AddPlaceOfOriginToPerson < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :place_of_origin, :string, default: nil
  end
end
