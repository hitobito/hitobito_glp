# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class AddPeopleAttrs < ActiveRecord::Migration[4.2]
  def change
    add_column :people, :title, :string
    add_column :people, :preferred_language, :string
    add_column :people, :joining_journey, :text
    add_column :people, :occupation, :string
    add_column :people, :joined_at, :date
    add_column :people, :left_at, :date
    add_column :people, :website_url, :string
  end
end
