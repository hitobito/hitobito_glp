class AddMailingListPeopleFilterAttrs < ActiveRecord::Migration
  def change
    add_column :mailing_lists, :age_start, :integer
    add_column :mailing_lists, :age_finish, :integer
    add_column :mailing_lists, :genders, :string
    add_column :mailing_lists, :languages, :string
  end
end
