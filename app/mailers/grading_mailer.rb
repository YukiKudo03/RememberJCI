# frozen_string_literal: true

class GradingMailer < ApplicationMailer
  def graded(submission)
    @submission = submission
    @user = submission.user
    @test = submission.test

    mail(
      to: @user.email,
      subject: "【RememberIt】テストの採点が完了しました"
    )
  end
end
