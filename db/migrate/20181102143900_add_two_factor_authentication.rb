class AddTwoFactorAuthentication < ActiveRecord::Migration
  def change
    add_column :people, :second_factor_code, :string
    add_column :people, :second_factor_generated_at, :datetime
    add_column :people, :second_factor_unsuccessful_tries, :integer, default: 0
  end
end
