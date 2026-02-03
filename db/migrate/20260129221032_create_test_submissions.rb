class CreateTestSubmissions < ActiveRecord::Migration[8.0]
  def change
    create_table :test_submissions do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
