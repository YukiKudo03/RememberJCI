class AddFieldsToLearningProgresses < ActiveRecord::Migration[8.0]
  def change
    add_column :learning_progresses, :current_level, :integer, default: 0
    add_column :learning_progresses, :best_score, :integer, default: 0
    add_column :learning_progresses, :total_attempts, :integer, default: 0
    add_column :learning_progresses, :total_study_time, :integer, default: 0
    add_index :learning_progresses, [:user_id, :text_id], unique: true
  end
end
