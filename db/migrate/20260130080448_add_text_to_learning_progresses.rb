class AddTextToLearningProgresses < ActiveRecord::Migration[8.0]
  def change
    add_reference :learning_progresses, :text, null: true, foreign_key: true
  end
end
