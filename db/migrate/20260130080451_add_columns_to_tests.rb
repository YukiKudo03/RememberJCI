class AddColumnsToTests < ActiveRecord::Migration[8.0]
  def change
    add_column :tests, :title, :string
    add_column :tests, :test_type, :integer
    add_column :tests, :time_limit, :integer
    add_column :tests, :available_from, :datetime
    add_column :tests, :available_until, :datetime
    add_reference :tests, :created_by, null: false, foreign_key: { to_table: :users }
  end
end
