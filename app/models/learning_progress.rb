# app/models/learning_progress.rb
class LearningProgress < ApplicationRecord
  belongs_to :user
  belongs_to :text

  validates :current_level, inclusion: { in: 0..5 }
  validates :user_id, uniqueness: { scope: :text_id }

  def completion_percentage
    (current_level / 5.0 * 100).to_i
  end

  def mastered?
    current_level == 5 && best_score == 100
  end
end
