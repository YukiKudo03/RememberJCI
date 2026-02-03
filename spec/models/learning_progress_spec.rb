# spec/models/learning_progress_spec.rb
require 'rails_helper'

RSpec.describe LearningProgress, type: :model do
  describe "バリデーション" do
    context "current_level" do
      it "0から5の範囲内であれば有効" do
        (0..5).each do |level|
          progress = build(:learning_progress, current_level: level)
          expect(progress).to be_valid
        end
      end

      it "範囲外の値は無効" do
        progress = build(:learning_progress, current_level: 6)
        expect(progress).not_to be_valid
      end
    end

    context "一意性制約" do
      it "同じユーザー・テキストの組み合わせは1つだけ" do
        existing = create(:learning_progress)
        duplicate = build(:learning_progress,
          user: existing.user,
          text: existing.text)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:text) }
  end

  describe "#completion_percentage" do
    it "レベルに基づいて完了率を返す" do
      progress = build(:learning_progress, current_level: 3)
      expect(progress.completion_percentage).to eq(60) # 3/5 * 100
    end
  end

  describe "#mastered?" do
    it "レベル5で100%スコアならtrueを返す" do
      progress = build(:learning_progress, current_level: 5, best_score: 100)
      expect(progress).to be_mastered
    end

    it "レベル5未満ならfalseを返す" do
      progress = build(:learning_progress, current_level: 4, best_score: 100)
      expect(progress).not_to be_mastered
    end
  end
end
