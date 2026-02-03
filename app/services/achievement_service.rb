# frozen_string_literal: true

# 達成バッジの判定・付与サービス
#
# 要件参照: US-L05（達成バッジシステム）
#
# @example
#   AchievementService.new(user).check_and_award
class AchievementService
  def initialize(user)
    @user = user
  end

  def check_and_award
    check_all_texts_mastered
  end

  private

  def check_all_texts_mastered
    return if @user.achievements.exists?(badge_type: "all_texts_mastered")

    assigned_text_ids = assigned_text_ids_for(@user)
    return if assigned_text_ids.empty?

    mastered_text_ids = @user.learning_progresses
                             .where(text_id: assigned_text_ids, current_level: 5, best_score: 100)
                             .pluck(:text_id)

    return unless (assigned_text_ids - mastered_text_ids).empty?

    @user.achievements.create!(
      badge_type: "all_texts_mastered",
      awarded_at: Time.current,
      metadata: { mastered_count: assigned_text_ids.size }
    )
  end

  def assigned_text_ids_for(user)
    direct = Assignment.where(user: user).pluck(:text_id)
    via_group = Assignment.where(group: user.groups).pluck(:text_id)
    (direct + via_group).uniq
  end
end
