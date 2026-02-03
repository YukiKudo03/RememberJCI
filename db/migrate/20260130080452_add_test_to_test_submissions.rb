class AddTestToTestSubmissions < ActiveRecord::Migration[8.0]
  def change
    add_reference :test_submissions, :test, null: false, foreign_key: true
  end
end
