# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Achievement Badge Display", type: :request do
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text1) { create(:text, created_by: teacher) }

  before do
    create(:assignment, :to_user, user: learner, text: text1, assigned_by: teacher)
    sign_in learner
  end

  describe "GET /learning/progress" do
    context "バッジが付与されている場合" do
      before do
        create(:learning_progress, user: learner, text: text1, current_level: 5, best_score: 100)
        Achievement.create!(user: learner, badge_type: "all_texts_mastered", awarded_at: Time.current)
      end

      it "バッジが表示される" do
        get learning_progress_index_path
        expect(response.body).to include("全テキストマスター達成")
      end

      it "バッジの授与日時が表示される" do
        get learning_progress_index_path
        expect(response.body).to include("達成日")
      end
    end

    context "バッジが付与されていない場合" do
      it "バッジセクションが表示されない" do
        get learning_progress_index_path
        expect(response.body).not_to include("達成バッジ")
      end
    end
  end
end
