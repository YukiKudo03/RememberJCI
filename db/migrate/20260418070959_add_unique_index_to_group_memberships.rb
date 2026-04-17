class AddUniqueIndexToGroupMemberships < ActiveRecord::Migration[8.0]
  def up
    # Clean up any existing duplicates before adding the unique index.
    # Without this, the migration fails on databases that already contain duplicate rows.
    duplicate_ids = execute(<<~SQL).to_a.flat_map { |row| row.values }
      SELECT id FROM (
        SELECT id,
               ROW_NUMBER() OVER (PARTITION BY user_id, group_id ORDER BY id ASC) AS rn
        FROM group_memberships
      ) ranked
      WHERE ranked.rn > 1
    SQL

    if duplicate_ids.any?
      execute("DELETE FROM group_memberships WHERE id IN (#{duplicate_ids.join(',')})")
    end

    add_index :group_memberships, [:user_id, :group_id], unique: true, name: "index_group_memberships_on_user_and_group"
  end

  def down
    remove_index :group_memberships, name: "index_group_memberships_on_user_and_group"
  end
end
