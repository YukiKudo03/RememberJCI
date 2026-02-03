# frozen_string_literal: true

# ReminderMailer - リマインダーメール送信
#
# 期限が近いアサインメントについてユーザーに通知する
#
class ReminderMailer < ApplicationMailer
  # 期限リマインダーメール
  #
  # @param assignment [Assignment] アサインメント
  # @param user [User] 送信先ユーザー
  def deadline_reminder(assignment, user)
    @assignment = assignment
    @user = user
    @text = assignment.text
    @deadline = assignment.deadline

    mail(
      to: user.email,
      subject: "【RememberIt】期限が近づいています: #{@text.title}"
    )
  end
end
