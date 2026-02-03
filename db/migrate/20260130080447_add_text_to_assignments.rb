class AddTextToAssignments < ActiveRecord::Migration[8.0]
  def change
    add_reference :assignments, :text, null: true, foreign_key: true
  end
end
