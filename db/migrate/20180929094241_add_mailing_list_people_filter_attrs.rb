# encoding: utf-8

#  Copyright (c) 2012-2019, GLP Schweiz. This file is part of
#  hitobito_glp and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_glp.


class AddMailingListPeopleFilterAttrs < ActiveRecord::Migration[4.2]
  def change
    add_column :mailing_lists, :age_start, :integer
    add_column :mailing_lists, :age_finish, :integer
    add_column :mailing_lists, :genders, :string
    add_column :mailing_lists, :languages, :string

    MailingList.reset_column_information
  end
end
