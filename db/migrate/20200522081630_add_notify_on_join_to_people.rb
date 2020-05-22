class AddNotifyOnJoinToPeople < ActiveRecord::Migration[6.0]
  def change
    add_column(:people, :notify_on_join, :boolean, default: true, null: false)
  end
end
