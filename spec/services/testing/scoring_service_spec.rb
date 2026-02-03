# spec/services/testing/scoring_service_spec.rb
require 'rails_helper'

RSpec.describe Testing::ScoringService do
  let(:admin) { create(:user, :admin) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, content: "これは テスト 文章 です", created_by: admin) }
  let(:test_record) { create(:test, text: text, created_by: admin) }
  let(:submission) { create(:test_submission, test: test_record, user: learner) }
  let(:service) { described_class.new(submission: submission) }

  describe "#calculate_score" do
    context "完全一致の場合" do
      before { submission.update(submitted_text: "これは テスト 文章 です") }

      it "100点を返す" do
        expect(service.calculate_score).to eq(100.0)
      end
    end

    context "部分一致の場合" do
      before { submission.update(submitted_text: "これは テスト 違う です") }

      it "正答率に基づいたスコアを返す" do
        expect(service.calculate_score).to eq(75.0) # 3/4 * 100
      end
    end

    context "完全不一致の場合" do
      before { submission.update(submitted_text: "全く 違う 内容 だ") }

      it "0点を返す" do
        expect(service.calculate_score).to eq(0.0)
      end
    end

    context "空の入力の場合" do
      before { submission.update(submitted_text: "") }

      it "0点を返す" do
        expect(service.calculate_score).to eq(0.0)
      end
    end

    context "nilの入力の場合" do
      before { submission.update(submitted_text: nil) }

      it "0点を返す" do
        expect(service.calculate_score).to eq(0.0)
      end
    end

    context "句読点や空白の違いを許容する場合" do
      before { submission.update(submitted_text: "これは  テスト  文章  です") }

      it "空白の違いを無視してスコアを計算する" do
        expect(service.calculate_score).to eq(100.0)
      end
    end
  end

  describe "#diff" do
    context "部分的に間違いがある場合" do
      before { submission.update(submitted_text: "これは 間違い 文章 です") }

      it "差分情報を含むハッシュを返す" do
        result = service.diff
        expect(result).to be_a(Array)
      end

      it "正解部分と間違い部分を区別する" do
        result = service.diff
        expect(result.any? { |d| d[:type] == :equal }).to be true
        expect(result.any? { |d| d[:type] == :delete || d[:type] == :insert }).to be true
      end
    end

    context "完全一致の場合" do
      before { submission.update(submitted_text: "これは テスト 文章 です") }

      it "全て正解として返す" do
        result = service.diff
        expect(result.all? { |d| d[:type] == :equal }).to be true
      end
    end
  end

  describe "#grade!" do
    before { submission.update(submitted_text: "これは テスト 文章 です") }

    it "submissionのauto_scoreを更新する" do
      expect { service.grade! }.to change { submission.reload.auto_score }.from(nil).to(100)
    end

    it "submissionのstatusをauto_gradedに更新する" do
      expect { service.grade! }.to change { submission.reload.status }.from("pending").to("auto_graded")
    end

    it "スコアを返す" do
      expect(service.grade!).to eq(100.0)
    end

    it "採点完了通知メールが送信される" do
      expect {
        service.grade!
      }.to have_enqueued_mail(GradingMailer, :graded)
    end
  end
end
