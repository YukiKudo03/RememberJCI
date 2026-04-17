class CreateGroupInvites < ActiveRecord::Migration[8.0]
  def change
    create_table :group_invites do |t|
      t.references :group, null: false, foreign_key: true, index: true
      t.references :created_by, null: false, foreign_key: { to_table: :users }, index: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.integer :max_uses, null: false, default: 10
      t.integer :uses_count, null: false, default: 0
      t.datetime :revoked_at

      t.timestamps
    end

    add_index :group_invites, :token, unique: true
    add_index :group_invites, [:group_id, :revoked_at]
  end
end
