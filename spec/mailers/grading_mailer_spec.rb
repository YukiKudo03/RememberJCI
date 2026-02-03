# frozen_string_literal: true

require "rails_helper"

RSpec.describe GradingMailer, type: :mailer do
  describe "#graded" do
    let(:teacher) { create(:user, :teacher, name: "田中先生") }
    let(:learner) { create(:user, :learner, email: "learner@example.com", name: "学習者") }
    let(:text) { create(:text, title: "テスト用テキスト", created_by: teacher) }
    let(:test_record) { create(:test, text: text, title: "暗記テスト", created_by: teacher) }
    let(:submission) { create(:test_submission, test: test_record, user: learner, auto_score: 85, status: :auto_graded) }
    let(:mail) { described_class.graded(submission) }

    it "送信先が学習者のメールアドレスである" do
      expect(mail.to).to eq(["learner@example.com"])
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("【RememberIt】テストの採点が完了しました")
    end

    it "本文にテスト名が含まれる" do
      expect(mail.body.encoded).to include("暗記テスト")
    end

    it "本文にスコアが含まれる" do
      expect(mail.body.encoded).to include("85")
    end

    it "本文に学習者名が含まれる" do
      expect(mail.body.encoded).to include("学習者")
    end
  end
end
