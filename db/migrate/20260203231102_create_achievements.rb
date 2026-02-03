class CreateAchievements < ActiveRecord::Migration[8.0]
  def change
    create_table :achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.string :badge_type, null: false
      t.datetime :awarded_at, null: false
      t.jsonb :metadata, default: {}

      t.timestamps
    end

    add_index :achievements, [:user_id, :badge_type], unique: true
  end
end
