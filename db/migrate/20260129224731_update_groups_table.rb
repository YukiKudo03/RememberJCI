class UpdateGroupsTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :groups, :name, false
    add_column :groups, :description, :text
    add_reference :groups, :created_by, null: false, foreign_key: { to_table: :users }
    add_index :groups, :name
  end
end
