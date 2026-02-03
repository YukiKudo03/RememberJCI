# Assignmentモデル - テキストをユーザーまたはグループに割り当てる
class Assignment < ApplicationRecord
  # 関連
  belongs_to :text
  belongs_to :user, optional: true
  belongs_to :group, optional: true
  belongs_to :assigned_by, class_name: "User"

  # バリデーション
  validate :user_or_group_must_be_present

  # 期限切れかどうかを判定
  def overdue?
    return false if deadline.nil?

    deadline < Time.current
  end

  private

  def user_or_group_must_be_present
    if user.nil? && group.nil?
      errors.add(:base, "ユーザーまたはグループを指定してください")
    end
  end
end
