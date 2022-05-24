# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class RemoveTwoFactorAuthentication < ActiveRecord::Migration[6.1]
  def change
    remove_column :people, :second_factor_code, :string
    remove_column :people, :second_factor_generated_at, :datetime
    remove_column :people, :second_factor_unsuccessful_tries, :integer, default: 0
  end
end
