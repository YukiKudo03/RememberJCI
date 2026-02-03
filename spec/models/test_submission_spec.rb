# spec/models/test_submission_spec.rb
require 'rails_helper'

RSpec.describe TestSubmission, type: :model do
  describe "バリデーション" do
    context "一意性制約" do
      it "同じユーザーは同じテストに1回だけ提出できる" do
        existing = create(:test_submission)
        duplicate = build(:test_submission,
          test: existing.test,
          user: existing.user)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "ステータス（status）" do
    it "pending, auto_graded, manually_gradedの3種類がある" do
      expect(TestSubmission.statuses.keys).to contain_exactly(
        "pending", "auto_graded", "manually_graded"
      )
    end

    it "デフォルトはpending" do
      submission = create(:test_submission)
      expect(submission).to be_pending
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:test) }
    it { is_expected.to belong_to(:user) }
  end

  describe "#final_score" do
    context "手動採点がある場合" do
      it "手動スコアを返す" do
        submission = build(:test_submission, auto_score: 80, manual_score: 90)
        expect(submission.final_score).to eq(90)
      end
    end

    context "手動採点がない場合" do
      it "自動スコアを返す" do
        submission = build(:test_submission, auto_score: 80, manual_score: nil)
        expect(submission.final_score).to eq(80)
      end
    end
  end

  describe "音声録音（audio_recording）" do
    describe "#has_audio?" do
      context "音声ファイルが添付されている場合" do
        it "trueを返す" do
          submission = create(:test_submission)
          submission.audio_recording.attach(
            io: StringIO.new("fake audio data"),
            filename: "test.webm",
            content_type: "audio/webm"
          )
          expect(submission.has_audio?).to be true
        end
      end

      context "音声ファイルが添付されていない場合" do
        it "falseを返す" do
          submission = create(:test_submission)
          expect(submission.has_audio?).to be false
        end
      end
    end

    describe "バリデーション" do
      context "サポートされている形式の場合" do
        it "有効である" do
          submission = create(:test_submission)
          submission.audio_recording.attach(
            io: StringIO.new("fake audio data"),
            filename: "test.webm",
            content_type: "audio/webm"
          )
          expect(submission).to be_valid
        end
      end

      context "サポートされていない形式の場合" do
        it "無効である" do
          submission = create(:test_submission)
          submission.audio_recording.attach(
            io: StringIO.new("fake text data"),
            filename: "test.txt",
            content_type: "text/plain"
          )
          expect(submission).not_to be_valid
          expect(submission.errors[:audio_recording]).to include("はサポートされていない形式です")
        end
      end
    end

    describe "#audio_url" do
      context "音声ファイルが添付されている場合" do
        it "URLを返す" do
          submission = create(:test_submission)
          submission.audio_recording.attach(
            io: StringIO.new("fake audio data"),
            filename: "test.webm",
            content_type: "audio/webm"
          )
          expect(submission.audio_url).to be_present
        end
      end

      context "音声ファイルが添付されていない場合" do
        it "nilを返す" do
          submission = create(:test_submission)
          expect(submission.audio_url).to be_nil
        end
      end
    end
  end
end
