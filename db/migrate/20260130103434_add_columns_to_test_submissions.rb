class AddColumnsToTestSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :test_submissions, :submitted_text, :text
    add_column :test_submissions, :auto_score, :integer
    add_column :test_submissions, :manual_score, :integer
    add_column :test_submissions, :status, :integer, default: 0
    add_column :test_submissions, :audio_file_path, :string
    add_index :test_submissions, [:test_id, :user_id], unique: true
  end
end
