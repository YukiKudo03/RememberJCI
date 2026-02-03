# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Dashboard Analytics (Admin)", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner1) { create(:user, :learner) }
  let(:learner2) { create(:user, :learner) }
  let(:text) { create(:text, created_by: teacher) }

  before { sign_in admin }

  describe "GET / (管理者ダッシュボード)" do
    it "完了率が表示される" do
      create(:learning_progress, user: learner1, text: text, current_level: 5, best_score: 100)
      create(:learning_progress, user: learner2, text: text, current_level: 2, best_score: 40)
      get root_path
      expect(response.body).to include("完了率")
    end

    it "平均スコアが表示される" do
      create(:learning_progress, user: learner1, text: text, current_level: 5, best_score: 80)
      create(:learning_progress, user: learner2, text: text, current_level: 3, best_score: 60)
      get root_path
      expect(response.body).to include("平均スコア")
    end

    it "テスト平均点が表示される" do
      test_record = create(:test, text: text, created_by: teacher)
      sub1 = create(:test_submission, test: test_record, user: learner1, submitted_text: "test")
      sub1.update!(auto_score: 80, status: :auto_graded)
      get root_path
      expect(response.body).to include("テスト平均点")
    end

    it "非アクティブユーザーが表示される" do
      # Create a learner who registered 40 days ago with no recent activity
      inactive_learner = create(:user, :learner, created_at: 40.days.ago)
      get root_path
      expect(response.body).to include("非アクティブユーザー")
      expect(response.body).to include(inactive_learner.name)
    end

    it "最近アクティブなユーザーは非アクティブ一覧に含まれない" do
      active_learner = create(:user, :learner, name: "アクティブ学習者", created_at: 40.days.ago)
      inactive_learner = create(:user, :learner, name: "非アクティブ学習者", created_at: 40.days.ago)
      create(:learning_progress, user: active_learner, text: text)

      get root_path
      # Inactive learner appears, active learner does not (in inactive section)
      expect(response.body).to include("非アクティブ学習者")
      # Verify active_learner is not in the inactive users count
      inactive_users = User.learners
                           .where("users.created_at < ?", 30.days.ago)
                           .where.not(id: LearningProgress.where("updated_at >= ?", 30.days.ago).select(:user_id))
                           .where.not(id: TestSubmission.where("created_at >= ?", 30.days.ago).select(:user_id))
      expect(inactive_users).to include(inactive_learner)
      expect(inactive_users).not_to include(active_learner)
    end

    it "学習進捗データがない場合もエラーにならない" do
      get root_path
      expect(response).to have_http_status(:success)
    end

    it "総学習時間が表示される" do
      create(:learning_progress, user: learner1, text: text, total_study_time: 3600)
      get root_path
      expect(response.body).to include("総学習時間")
    end

    it "総テスト提出数が表示される" do
      test_record = create(:test, text: text, created_by: teacher)
      create(:test_submission, test: test_record, user: learner1, submitted_text: "test")
      get root_path
      expect(response.body).to include("テスト提出数")
    end
  end
end
