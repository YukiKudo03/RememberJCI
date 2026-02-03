# spec/services/learning/practice_service_spec.rb
require 'rails_helper'

RSpec.describe Learning::PracticeService do
  let(:user) { create(:user) }
  let(:text) { create(:text, content: "これは テスト 文章 です") }
  let(:service) { described_class.new(user: user, text: text) }

  describe "#progress" do
    context "進捗が存在しない場合" do
      it "新しい進捗が作成される" do
        expect { service.progress }.to change(LearningProgress, :count).by(1)
      end
    end

    context "進捗が既に存在する場合" do
      let!(:existing) { create(:learning_progress, user: user, text: text) }

      it "既存の進捗が返される" do
        expect(service.progress).to eq(existing)
      end
    end
  end

  describe "#content_with_blanks" do
    context "レベル0の場合" do
      it "全文を返す" do
        result = service.content_with_blanks(level: 0)
        expect(result).to eq(text.content)
      end
    end

    context "レベル1の場合" do
      it "約20%の単語が空欄になる" do
        result = service.content_with_blanks(level: 1)
        blank_count = result.scan(/_{2,}/).count
        word_count = text.content.split.count
        expect(blank_count).to be_within(1).of(word_count * 0.2)
      end
    end

    context "レベル5の場合" do
      it "すべての単語が空欄になる" do
        result = service.content_with_blanks(level: 5)
        expect(result).not_to include("これは")
        expect(result).not_to include("テスト")
      end
    end
  end

  describe "#save_attempt" do
    it "進捗が更新される" do
      service.save_attempt(level: 2, time_spent: 60, score: 80)
      progress = service.progress

      expect(progress.current_level).to eq(2)
      expect(progress.total_study_time).to eq(60)
      expect(progress.best_score).to eq(80)
    end

    it "best_scoreは最高値が保持される" do
      service.save_attempt(level: 1, time_spent: 30, score: 90)
      service.save_attempt(level: 2, time_spent: 30, score: 70)

      expect(service.progress.best_score).to eq(90)
    end
  end
end
