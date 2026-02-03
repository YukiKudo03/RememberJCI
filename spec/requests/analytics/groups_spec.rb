# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Analytics::Groups", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:learner1) { create(:user, :learner) }
  let(:learner2) { create(:user, :learner) }
  let(:group) { create(:group, created_by: teacher) }
  let(:text) { create(:text, created_by: admin) }

  before do
    group.add_member(learner1)
    group.add_member(learner2)
  end

  describe "GET /analytics/groups" do
    context "教師の場合" do
      before { sign_in teacher }

      it "成功する" do
        get analytics_groups_path
        expect(response).to have_http_status(:success)
      end

      it "自分のグループが表示される" do
        get analytics_groups_path
        expect(response.body).to include(group.name)
      end

      it "他の教師のグループは表示されない" do
        other_group = create(:group, name: "他のグループ", created_by: other_teacher)
        get analytics_groups_path
        expect(response.body).not_to include("他のグループ")
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get analytics_groups_path
        expect(response).to have_http_status(:success)
      end

      it "全グループが表示される" do
        other_group = create(:group, name: "他のグループ", created_by: other_teacher)
        get analytics_groups_path
        expect(response.body).to include(group.name)
        expect(response.body).to include("他のグループ")
      end
    end

    context "学習者の場合" do
      before { sign_in learner1 }

      it "アクセスが拒否される" do
        get analytics_groups_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /analytics/groups/:id" do
    context "グループ作成者（教師）の場合" do
      before { sign_in teacher }

      it "成功する" do
        get analytics_group_path(group)
        expect(response).to have_http_status(:success)
      end

      it "グループ名が表示される" do
        get analytics_group_path(group)
        expect(response.body).to include(group.name)
      end

      it "メンバー一覧が表示される" do
        get analytics_group_path(group)
        expect(response.body).to include(learner1.name)
        expect(response.body).to include(learner2.name)
      end

      context "学習進捗がある場合" do
        before do
          create(:learning_progress, user: learner1, text: text, current_level: 3, best_score: 80)
          create(:learning_progress, user: learner2, text: text, current_level: 5, best_score: 100)
        end

        it "進捗情報が表示される" do
          get analytics_group_path(group)
          expect(response.body).to include("60%") # learner1: level 3/5 = 60%
          expect(response.body).to include("100%") # learner2: level 5/5 = 100%
        end
      end

      context "テスト提出がある場合" do
        let(:test_record) { create(:test, text: text, created_by: teacher) }

        before do
          create(:test_submission, :auto_graded, test: test_record, user: learner1, auto_score: 75)
          create(:test_submission, :auto_graded, test: test_record, user: learner2, auto_score: 95)
        end

        it "テストスコアが表示される" do
          get analytics_group_path(group)
          expect(response.body).to include("75")
          expect(response.body).to include("95")
        end
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get analytics_group_path(group)
        expect(response).to have_http_status(:success)
      end
    end

    context "別の教師の場合" do
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        get analytics_group_path(group)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "学習者の場合" do
      before { sign_in learner1 }

      it "アクセスが拒否される" do
        get analytics_group_path(group)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /analytics/groups/:id/members/:member_id" do
    context "グループ作成者（教師）の場合" do
      before { sign_in teacher }

      it "成功する" do
        get member_analytics_group_path(group, learner1)
        expect(response).to have_http_status(:success)
      end

      it "学習者名が表示される" do
        get member_analytics_group_path(group, learner1)
        expect(response.body).to include(learner1.name)
      end

      context "学習進捗がある場合" do
        before do
          create(:learning_progress, user: learner1, text: text, current_level: 4, best_score: 90)
        end

        it "テキストごとの進捗が表示される" do
          get member_analytics_group_path(group, learner1)
          expect(response.body).to include(text.title)
          expect(response.body).to include("80%") # level 4/5 = 80%
        end
      end
    end

    context "別の教師の場合" do
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        get member_analytics_group_path(group, learner1)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
