class AddFeedbackToTestSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_column :test_submissions, :feedback, :text
  end
end
