# spec/requests/learning/progress_spec.rb
require 'rails_helper'

RSpec.describe "Learning::Progress", type: :request do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:admin) { create(:user, :admin) }
  let(:text1) { create(:text, created_by: admin) }
  let(:text2) { create(:text, created_by: admin) }
  let(:group) { create(:group, created_by: teacher) }

  before do
    # Assign texts to learner
    create(:assignment, :to_user, user: learner, text: text1, assigned_by: teacher)
    create(:assignment, :to_group, group: group, text: text2, assigned_by: teacher)
    create(:group_membership, user: learner, group: group)
  end

  describe "GET /learning/progress" do
    context "学習者としてログインしている場合" do
      before { sign_in learner }

      it "成功する" do
        get learning_progress_index_path
        expect(response).to have_http_status(:success)
      end

      it "アサインされたテキストの進捗が表示される" do
        create(:learning_progress, user: learner, text: text1, current_level: 3)
        get learning_progress_index_path
        expect(response.body).to include(text1.title)
      end

      it "進捗がないテキストも表示される" do
        get learning_progress_index_path
        expect(response.body).to include(text1.title)
        expect(response.body).to include(text2.title)
      end

      it "進捗率が表示される" do
        create(:learning_progress, user: learner, text: text1, current_level: 3)
        get learning_progress_index_path
        expect(response.body).to include("60%")
      end

      it "学習時間が表示される" do
        create(:learning_progress, user: learner, text: text1, total_study_time: 300)
        get learning_progress_index_path
        expect(response.body).to include("5分")
      end
    end

    context "教師としてログインしている場合" do
      before { sign_in teacher }

      it "自分の進捗が表示される" do
        create(:assignment, :to_user, user: teacher, text: text1, assigned_by: admin)
        get learning_progress_index_path
        expect(response).to have_http_status(:success)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get learning_progress_index_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /learning/progress/:id" do
    let!(:progress) { create(:learning_progress, user: learner, text: text1, current_level: 4, best_score: 85, total_study_time: 600) }

    context "学習者としてログインしている場合" do
      before { sign_in learner }

      it "成功する" do
        get learning_progress_path(progress)
        expect(response).to have_http_status(:success)
      end

      it "テキスト情報が表示される" do
        get learning_progress_path(progress)
        expect(response.body).to include(text1.title)
      end

      it "詳細な進捗情報が表示される" do
        get learning_progress_path(progress)
        expect(response.body).to include("レベル 4")
        expect(response.body).to include("85")
      end
    end

    context "他のユーザーの進捗の場合" do
      let(:other_learner) { create(:user, :learner) }
      let(:other_progress) { create(:learning_progress, user: other_learner, text: text1) }

      before { sign_in learner }

      it "アクセスが拒否される" do
        get learning_progress_path(other_progress)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "進捗統計" do
    before { sign_in learner }

    it "完了したテキスト数が表示される" do
      create(:learning_progress, user: learner, text: text1, current_level: 5, best_score: 100)
      create(:learning_progress, user: learner, text: text2, current_level: 3)
      get learning_progress_index_path
      expect(response.body).to include("1 / 2")
    end

    it "総学習時間が表示される" do
      create(:learning_progress, user: learner, text: text1, total_study_time: 300)
      create(:learning_progress, user: learner, text: text2, total_study_time: 600)
      get learning_progress_index_path
      expect(response.body).to include("15分")
    end
  end
end
