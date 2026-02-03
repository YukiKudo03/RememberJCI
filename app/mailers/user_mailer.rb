# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def welcome(user)
    @user = user
    mail(
      to: user.email,
      subject: "【RememberIt】アカウントが作成されました"
    )
  end
end
