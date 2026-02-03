class CreateTexts < ActiveRecord::Migration[8.0]
  def change
    create_table :texts do |t|
      t.string :title, null: false
      t.text :content, null: false
      t.string :category
      t.integer :difficulty, default: 1, null: false # 0=easy, 1=medium, 2=hard
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.timestamps
    end

    add_index :texts, :title
    add_index :texts, :category
    add_index :texts, :difficulty
  end
end
