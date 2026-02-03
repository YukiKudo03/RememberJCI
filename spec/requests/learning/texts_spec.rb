# spec/requests/learning/texts_spec.rb
require 'rails_helper'

RSpec.describe "Learning::Texts", type: :request do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:text) { create(:text, created_by: teacher) }

  describe "GET /learning/texts" do
    context "学習者としてログインしている場合" do
      before { sign_in learner }

      it "成功する" do
        get learning_texts_path
        expect(response).to have_http_status(:success)
      end

      it "アサインされたテキストが表示される" do
        assignment = create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
        get learning_texts_path
        expect(response.body).to include(text.title)
      end

      it "アサインされていないテキストは表示されない" do
        other_learner = create(:user, :learner)
        assignment = create(:assignment, :to_user, user: other_learner, text: text, assigned_by: teacher)
        get learning_texts_path
        expect(response.body).not_to include(text.title)
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get learning_texts_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "GET /learning/texts/:id" do
    let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher) }

    context "学習者としてログインしている場合" do
      before { sign_in learner }

      it "成功する" do
        get learning_text_path(text)
        expect(response).to have_http_status(:success)
      end

      it "テキスト内容が表示される" do
        get learning_text_path(text)
        expect(response.body).to include(text.title)
      end
    end

    context "アサインされていないテキストの場合" do
      let(:other_text) { create(:text, created_by: teacher) }

      before { sign_in learner }

      it "アクセスが拒否される" do
        get learning_text_path(other_text)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /learning/texts/:id/practice" do
    let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher) }

    before { sign_in learner }

    it "成功する" do
      get practice_learning_text_path(text)
      expect(response).to have_http_status(:success)
    end

    it "レベルパラメータで空欄の割合が変わる" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include(text.content)
    end
  end

  describe "POST /learning/texts/:id/save_progress" do
    let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher) }

    before { sign_in learner }

    it "進捗が保存される" do
      expect {
        post save_progress_learning_text_path(text), params: { level: 2, time_spent: 60, score: 80 }
      }.to change(LearningProgress, :count).by(1)
    end

    it "JSONで結果が返される" do
      post save_progress_learning_text_path(text), params: { level: 2, time_spent: 60, score: 80 }
      expect(response.content_type).to include("application/json")
    end
  end
end
