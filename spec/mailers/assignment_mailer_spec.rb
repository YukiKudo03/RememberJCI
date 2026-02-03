# spec/mailers/assignment_mailer_spec.rb
require 'rails_helper'

RSpec.describe AssignmentMailer, type: :mailer do
  describe "#new_assignment" do
    let(:user) { create(:user, email: "learner@example.com", name: "学習者") }
    let(:teacher) { create(:user, :teacher, name: "田中先生") }
    let(:text) { create(:text, title: "暗記テキスト1", created_by: teacher) }
    let(:assignment) { create(:assignment, :to_user, user: user, text: text, assigned_by: teacher, deadline: 1.week.from_now) }
    let(:mail) { described_class.new_assignment(assignment, user) }

    it "送信先が正しい" do
      expect(mail.to).to eq(["learner@example.com"])
    end

    it "件名が正しい" do
      expect(mail.subject).to eq("【RememberIt】新しいテキストがアサインされました")
    end

    it "本文にテキストタイトルが含まれる" do
      expect(mail.body.encoded).to include("暗記テキスト1")
    end

    it "本文に期限が含まれる" do
      expect(mail.body.encoded).to include(assignment.deadline.strftime("%Y年%m月%d日"))
    end

    it "本文に割り当て者名が含まれる" do
      expect(mail.body.encoded).to include("田中先生")
    end

    context "期限がない場合" do
      let(:assignment) { create(:assignment, :to_user, user: user, text: text, assigned_by: teacher, deadline: nil) }

      it "期限なしと表示される" do
        expect(mail.body.encoded).to include("期限なし")
      end
    end
  end
end
