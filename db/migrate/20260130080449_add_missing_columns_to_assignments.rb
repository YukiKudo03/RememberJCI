class AddMissingColumnsToAssignments < ActiveRecord::Migration[8.0]
  def change
    # Make group_id optional (was required before)
    change_column_null :assignments, :group_id, true

    # Add user_id (optional - assignments can be to user OR group)
    add_reference :assignments, :user, null: true, foreign_key: true

    # Add assigned_by_id (required - who created the assignment)
    add_reference :assignments, :assigned_by, null: false, foreign_key: { to_table: :users }

    # Add deadline (optional)
    add_column :assignments, :deadline, :datetime
  end
end
