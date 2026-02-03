# frozen_string_literal: true

require "rails_helper"

RSpec.describe ReminderMailer, type: :mailer do
  describe "#deadline_reminder" do
    let(:teacher) { create(:user, :teacher) }
    let(:learner) { create(:user, :learner, name: "テスト学習者", email: "learner@example.com") }
    let(:text) { create(:text, title: "テスト暗唱テキスト", created_by: teacher) }
    let(:assignment) do
      create(:assignment,
             text: text,
             user: learner,
             assigned_by: teacher,
             deadline: 2.days.from_now)
    end
    let(:mail) { described_class.deadline_reminder(assignment, learner) }

    it "正しい宛先に送信される" do
      expect(mail.to).to eq(["learner@example.com"])
    end

    it "正しい件名が設定される" do
      expect(mail.subject).to eq("【RememberIt】期限が近づいています: テスト暗唱テキスト")
    end

    it "本文にユーザー名が含まれる" do
      # マルチパートメールではtext_partまたはhtml_partを使う
      expect(mail.text_part.body.decoded).to include("テスト学習者")
    end

    it "本文にテキスト名が含まれる" do
      expect(mail.text_part.body.decoded).to include("テスト暗唱テキスト")
    end

    it "本文に期限が含まれる" do
      # 日付が本文に含まれることを確認
      expect(mail.text_part.body.decoded).to include(assignment.deadline.year.to_s)
    end
  end
end
