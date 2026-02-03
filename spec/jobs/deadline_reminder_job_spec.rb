# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeadlineReminderJob, type: :job do
  describe "#perform" do
    let(:teacher) { create(:user, :teacher) }
    let(:learner) { create(:user, :learner) }
    let(:text) { create(:text, created_by: teacher) }

    context "期限が近いアサインメントがある場合" do
      let!(:assignment) do
        create(:assignment,
               text: text,
               user: learner,
               assigned_by: teacher,
               deadline: 1.day.from_now)
      end

      it "リマインダーメールが送信される" do
        expect {
          described_class.perform_now
        }.to have_enqueued_mail(ReminderMailer, :deadline_reminder)
      end

      it "正しいアサインメントとユーザーがメーラーに渡される" do
        expect(ReminderMailer).to receive(:deadline_reminder)
          .with(assignment, learner)
          .and_return(double(deliver_later: true))

        described_class.perform_now
      end
    end

    context "期限が過ぎたアサインメントがある場合" do
      let!(:overdue_assignment) do
        create(:assignment,
               text: text,
               user: learner,
               assigned_by: teacher,
               deadline: 1.day.ago)
      end

      it "リマインダーは送信されない" do
        expect {
          described_class.perform_now
        }.not_to have_enqueued_mail(ReminderMailer, :deadline_reminder)
      end
    end

    context "期限が3日以上先のアサインメントがある場合" do
      let!(:future_assignment) do
        create(:assignment,
               text: text,
               user: learner,
               assigned_by: teacher,
               deadline: 5.days.from_now)
      end

      it "リマインダーは送信されない" do
        expect {
          described_class.perform_now
        }.not_to have_enqueued_mail(ReminderMailer, :deadline_reminder)
      end
    end

    context "期限がないアサインメントがある場合" do
      let!(:no_deadline_assignment) do
        create(:assignment,
               text: text,
               user: learner,
               assigned_by: teacher,
               deadline: nil)
      end

      it "リマインダーは送信されない" do
        expect {
          described_class.perform_now
        }.not_to have_enqueued_mail(ReminderMailer, :deadline_reminder)
      end
    end

    context "グループアサインメントの場合" do
      let(:group) { create(:group, created_by: teacher) }
      let(:member1) { create(:user, :learner) }
      let(:member2) { create(:user, :learner) }
      let!(:group_assignment) do
        create(:assignment,
               text: text,
               group: group,
               user: nil,
               assigned_by: teacher,
               deadline: 1.day.from_now)
      end

      before do
        create(:group_membership, group: group, user: member1)
        create(:group_membership, group: group, user: member2)
      end

      it "グループの全メンバーにリマインダーが送信される" do
        expect {
          described_class.perform_now
        }.to have_enqueued_mail(ReminderMailer, :deadline_reminder).exactly(2).times
      end
    end

    context "複数の期限が近いアサインメントがある場合" do
      let(:learner2) { create(:user, :learner) }
      let!(:assignment1) do
        create(:assignment,
               text: text,
               user: learner,
               assigned_by: teacher,
               deadline: 1.day.from_now)
      end
      let!(:assignment2) do
        create(:assignment,
               text: text,
               user: learner2,
               assigned_by: teacher,
               deadline: 2.days.from_now)
      end

      it "全てのアサインメントについてリマインダーが送信される" do
        expect {
          described_class.perform_now
        }.to have_enqueued_mail(ReminderMailer, :deadline_reminder).exactly(2).times
      end
    end
  end

  describe "キュー設定" do
    it "defaultキューで実行される" do
      expect(described_class.new.queue_name).to eq("default")
    end
  end
end
