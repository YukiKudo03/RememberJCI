# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Learning::SelfTest", type: :request do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:text) { create(:text, title: "テスト用テキスト", content: "これは テスト 文章 です", created_by: teacher) }
  let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher) }

  describe "GET /learning/texts/:id/self_test" do
    before { sign_in learner }

    it "成功する" do
      get self_test_learning_text_path(text)
      expect(response).to have_http_status(:success)
    end

    it "テキストタイトルが表示される" do
      get self_test_learning_text_path(text)
      expect(response.body).to include("テスト用テキスト")
    end

    context "アサインされていないテキストの場合" do
      let(:other_text) { create(:text, created_by: teacher) }

      it "アクセスが拒否される" do
        get self_test_learning_text_path(other_text)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /learning/texts/:id/check_self_test" do
    before { sign_in learner }

    it "成功する" do
      post check_self_test_learning_text_path(text), params: { submitted_text: "これは テスト 文章 です" }
      expect(response).to have_http_status(:success)
    end

    it "スコアが表示される" do
      post check_self_test_learning_text_path(text), params: { submitted_text: "これは テスト 文章 です" }
      expect(response.body).to include("100")
    end

    it "差分が表示される" do
      post check_self_test_learning_text_path(text), params: { submitted_text: "これは 間違い 文章 です" }
      expect(response.body).to include("間違い")
    end

    it "進捗が更新される" do
      expect {
        post check_self_test_learning_text_path(text), params: { submitted_text: "これは テスト 文章 です" }
      }.to change(LearningProgress, :count).by(1)
    end

    context "アサインされていないテキストの場合" do
      let(:other_text) { create(:text, created_by: teacher) }

      it "アクセスが拒否される" do
        post check_self_test_learning_text_path(other_text), params: { submitted_text: "test" }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
