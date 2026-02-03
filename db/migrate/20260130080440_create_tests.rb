class CreateTests < ActiveRecord::Migration[8.0]
  def change
    create_table :tests do |t|
      t.references :text, null: false, foreign_key: true
      t.timestamps
    end
  end
end
