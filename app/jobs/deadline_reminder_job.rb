# frozen_string_literal: true

# DeadlineReminderJob - 期限が近いアサインメントのリマインダーを送信
#
# 要件参照: FR-31（アサインメントはオプションの期限をサポートする）
#
# このジョブは定期的に実行され、期限が近いアサインメントを持つ
# ユーザーにリマインダーメールを送信する
#
# 使用方法:
#   DeadlineReminderJob.perform_later  # 非同期実行
#   DeadlineReminderJob.perform_now    # 同期実行（テスト用）
#
# 定期実行の設定（cron等）:
#   毎日午前9時に実行: 0 9 * * * bundle exec rails runner "DeadlineReminderJob.perform_later"
#
class DeadlineReminderJob < ApplicationJob
  queue_as :default

  # リマインダーを送信する期限の範囲（現在から何日先まで）
  REMINDER_DAYS_BEFORE = 3

  def perform
    assignments_approaching_deadline.find_each do |assignment|
      send_reminders_for(assignment)
    end
  end

  private

  # 期限が近いアサインメントを取得
  # - 期限が設定されている
  # - 期限がまだ過ぎていない
  # - 期限が3日以内
  def assignments_approaching_deadline
    Assignment
      .where.not(deadline: nil)
      .where(deadline: Time.current..REMINDER_DAYS_BEFORE.days.from_now)
  end

  # アサインメントに対してリマインダーを送信
  def send_reminders_for(assignment)
    if assignment.user.present?
      # 個人アサインメント
      send_reminder(assignment, assignment.user)
    elsif assignment.group.present?
      # グループアサインメント - 全メンバーに送信
      assignment.group.members.find_each do |member|
        send_reminder(assignment, member)
      end
    end
  end

  # リマインダーメールを送信
  def send_reminder(assignment, user)
    ReminderMailer.deadline_reminder(assignment, user).deliver_later
  end
end
