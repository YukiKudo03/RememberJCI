# frozen_string_literal: true

require "rails_helper"

RSpec.describe AchievementService do
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text1) { create(:text, created_by: teacher) }
  let(:text2) { create(:text, created_by: teacher) }

  before do
    create(:assignment, :to_user, user: learner, text: text1, assigned_by: teacher)
    create(:assignment, :to_user, user: learner, text: text2, assigned_by: teacher)
  end

  describe "#check_and_award" do
    context "全テキストをマスターした場合" do
      before do
        create(:learning_progress, user: learner, text: text1, current_level: 5, best_score: 100)
        create(:learning_progress, user: learner, text: text2, current_level: 5, best_score: 100)
      end

      it "all_texts_masteredバッジが付与される" do
        expect {
          described_class.new(learner).check_and_award
        }.to change(Achievement, :count).by(1)
      end

      it "バッジのbadge_typeがall_texts_masteredである" do
        described_class.new(learner).check_and_award
        achievement = learner.achievements.last
        expect(achievement.badge_type).to eq("all_texts_mastered")
      end

      it "awarded_atが設定される" do
        described_class.new(learner).check_and_award
        achievement = learner.achievements.last
        expect(achievement.awarded_at).to be_present
      end

      it "二重付与されない" do
        described_class.new(learner).check_and_award
        expect {
          described_class.new(learner).check_and_award
        }.not_to change(Achievement, :count)
      end
    end

    context "一部のテキストのみマスターした場合" do
      before do
        create(:learning_progress, user: learner, text: text1, current_level: 5, best_score: 100)
        create(:learning_progress, user: learner, text: text2, current_level: 3, best_score: 80)
      end

      it "バッジが付与されない" do
        expect {
          described_class.new(learner).check_and_award
        }.not_to change(Achievement, :count)
      end
    end

    context "アサインされたテキストがない場合" do
      let(:other_learner) { create(:user, :learner) }

      it "バッジが付与されない" do
        expect {
          described_class.new(other_learner).check_and_award
        }.not_to change(Achievement, :count)
      end
    end
  end
end
