class SetPeopleDefaultPreferredLanguage < ActiveRecord::Migration[4.2]
  def up
    change_column_default(:people, :preferred_language, 'de')
    Person.reset_column_information
  end

  def down
    change_column_default(:people, :preferred_language, nil)
  end
end
