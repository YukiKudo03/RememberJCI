# frozen_string_literal: true

require "rails_helper"

RSpec.describe AssignmentNotificationJob, type: :job do
  include ActiveJob::TestHelper

  let(:teacher) { create(:user, :teacher) }
  let(:learner1) { create(:user, :learner, email: "learner1@example.com") }
  let(:learner2) { create(:user, :learner, email: "learner2@example.com") }
  let(:text) { create(:text, created_by: teacher) }
  let(:group) { create(:group, created_by: teacher) }

  describe "#perform" do
    context "ユーザーへのアサインメントの場合" do
      let(:assignment) { create(:assignment, :to_user, user: learner1, text: text, assigned_by: teacher) }

      it "指定ユーザーにメールを送信する" do
        expect {
          described_class.perform_now(assignment.id)
        }.to have_enqueued_mail(AssignmentMailer, :new_assignment).with(assignment, learner1)
      end
    end

    context "グループへのアサインメントの場合" do
      let(:assignment) { create(:assignment, :to_group, group: group, text: text, assigned_by: teacher) }

      before do
        group.add_member(learner1)
        group.add_member(learner2)
      end

      it "グループの全メンバーにメールを送信する" do
        expect {
          described_class.perform_now(assignment.id)
        }.to have_enqueued_mail(AssignmentMailer, :new_assignment).exactly(2).times
      end
    end

    context "アサインメントが存在しない場合" do
      it "エラーを発生させない" do
        expect {
          described_class.perform_now(-1)
        }.not_to raise_error
      end
    end
  end

  describe "ジョブのキュー設定" do
    it "notificationsキューで実行される" do
      expect(described_class.new.queue_name).to eq("notifications")
    end
  end
end
