class AddPeopleAttrs < ActiveRecord::Migration
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
