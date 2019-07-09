class SetPeopleDefaultPreferredLanguage < ActiveRecord::Migration
  def up
    change_column_default(:people, :preferred_language, to: :de)
    Person.reset_column_information
  end

  def down
    change_column_default(:people, :preferred_language, to: nil)
  end
end
