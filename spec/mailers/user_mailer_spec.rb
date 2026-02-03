# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMailer, type: :mailer do
  describe "#welcome" do
    let(:user) { create(:user, email: "new_user@example.com", name: "新規ユーザー") }
    let(:mail) { described_class.welcome(user) }

    it "送信先が正しい" do
      expect(mail.to).to eq(["new_user@example.com"])
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("【RememberIt】アカウントが作成されました")
    end

    it "本文にユーザー名が含まれる" do
      expect(mail.body.encoded).to include("新規ユーザー")
    end

    it "本文にログインリンクが含まれる" do
      expect(mail.body.encoded).to include("ログイン")
    end
  end
end
