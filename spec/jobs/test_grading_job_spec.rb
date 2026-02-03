# frozen_string_literal: true

require "rails_helper"

RSpec.describe TestGradingJob, type: :job do
  include ActiveJob::TestHelper

  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, content: "これは テスト 文章 です", created_by: admin) }
  let(:test_record) { create(:test, text: text, created_by: teacher) }
  let(:submission) { create(:test_submission, test: test_record, user: learner, submitted_text: "これは テスト 文章 です") }

  describe "#perform" do
    context "正常な提出の場合" do
      it "採点サービスを呼び出す" do
        expect_any_instance_of(Testing::ScoringService).to receive(:grade!)
        described_class.perform_now(submission.id)
      end

      it "提出のauto_scoreを更新する" do
        expect {
          described_class.perform_now(submission.id)
        }.to change { submission.reload.auto_score }.from(nil).to(100)
      end

      it "提出のstatusをauto_gradedに更新する" do
        expect {
          described_class.perform_now(submission.id)
        }.to change { submission.reload.status }.from("pending").to("auto_graded")
      end
    end

    context "部分一致の提出の場合" do
      let(:submission) { create(:test_submission, test: test_record, user: learner, submitted_text: "これは 違う 文章 です") }

      it "正答率に基づいたスコアを設定する" do
        described_class.perform_now(submission.id)
        expect(submission.reload.auto_score).to eq(75) # 3/4 * 100
      end
    end

    context "提出が存在しない場合" do
      it "エラーを発生させない" do
        expect {
          described_class.perform_now(-1)
        }.not_to raise_error
      end
    end

    context "提出IDがnilの場合" do
      it "エラーを発生させない" do
        expect {
          described_class.perform_now(nil)
        }.not_to raise_error
      end
    end

    context "既に採点済みの場合" do
      before do
        submission.update!(auto_score: 80, status: :auto_graded)
      end

      it "再採点してスコアを更新する" do
        described_class.perform_now(submission.id)
        expect(submission.reload.auto_score).to eq(100)
      end
    end
  end

  describe "ジョブのキュー設定" do
    it "gradingキューで実行される" do
      expect(described_class.new.queue_name).to eq("grading")
    end
  end

  describe "非同期実行" do
    it "ジョブがキューに追加される" do
      expect {
        described_class.perform_later(submission.id)
      }.to have_enqueued_job(described_class).with(submission.id).on_queue("grading")
    end
  end
end
