# spec/requests/tests_spec.rb
require 'rails_helper'

RSpec.describe "Tests", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: admin) }

  describe "GET /tests" do
    context "教師の場合" do
      before { sign_in teacher }

      it "成功する" do
        get tests_path
        expect(response).to have_http_status(:success)
      end

      it "自分が作成したテストが表示される" do
        test_record = create(:test, text: text, created_by: teacher)
        get tests_path
        expect(response.body).to include(test_record.title)
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get tests_path
        expect(response).to have_http_status(:success)
      end

      it "全テストが表示される" do
        test_record = create(:test, text: text, created_by: teacher)
        get tests_path
        expect(response.body).to include(test_record.title)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        get tests_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /tests/new" do
    context "教師の場合" do
      before { sign_in teacher }

      it "成功する" do
        get new_test_path
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "POST /tests" do
    context "教師の場合" do
      before { sign_in teacher }

      let(:valid_params) do
        {
          test: {
            title: "新しいテスト",
            text_id: text.id,
            test_type: "typing",
            time_limit: 30
          }
        }
      end

      it "テストが作成される" do
        expect {
          post tests_path, params: valid_params
        }.to change(Test, :count).by(1)
      end

      it "created_byが設定される" do
        post tests_path, params: valid_params
        expect(Test.last.created_by).to eq(teacher)
      end

      it "一覧にリダイレクトされる" do
        post tests_path, params: valid_params
        expect(response).to redirect_to(tests_path)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        post tests_path, params: { test: { title: "テスト", text_id: text.id } }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /tests/:id/take" do
    let(:test_record) { create(:test, :available_now, text: text, created_by: teacher) }
    let(:group) { create(:group, created_by: teacher) }

    before do
      # Assign the text to the learner
      create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "成功する" do
        get take_test_path(test_record)
        expect(response).to have_http_status(:success)
      end

      it "テスト情報が表示される" do
        get take_test_path(test_record)
        expect(response.body).to include(test_record.title)
      end
    end

    context "テキストがアサインされていない学習者の場合" do
      let(:other_learner) { create(:user, :learner) }
      before { sign_in other_learner }

      it "アクセスが拒否される" do
        get take_test_path(test_record)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "テストが利用可能期間外の場合" do
      let(:unavailable_test) { create(:test, text: text, created_by: teacher, available_from: 1.day.from_now) }

      before { sign_in learner }

      it "アクセスが拒否される" do
        get take_test_path(unavailable_test)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /tests/:id/submit" do
    let(:test_record) { create(:test, :available_now, text: text, created_by: teacher) }

    before do
      create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
    end

    context "学習者の場合" do
      before { sign_in learner }

      let(:submit_params) do
        {
          submission: {
            submitted_text: "提出されたテキスト"
          }
        }
      end

      it "提出が作成される" do
        expect {
          post submit_test_path(test_record), params: submit_params
        }.to change(TestSubmission, :count).by(1)
      end

      it "結果ページにリダイレクトされる" do
        post submit_test_path(test_record), params: submit_params
        expect(response).to redirect_to(result_test_path(test_record))
      end
    end
  end

  describe "GET /tests/:id/result" do
    let(:test_record) { create(:test, text: text, created_by: teacher) }
    let!(:submission) { create(:test_submission, :auto_graded, test: test_record, user: learner) }

    context "学習者の場合" do
      before { sign_in learner }

      it "成功する" do
        get result_test_path(test_record)
        expect(response).to have_http_status(:success)
      end

      it "スコアが表示される" do
        get result_test_path(test_record)
        expect(response.body).to include(submission.auto_score.to_s)
      end
    end

    context "提出していない学習者の場合" do
      let(:other_learner) { create(:user, :learner) }
      before { sign_in other_learner }

      it "リダイレクトされる" do
        get result_test_path(test_record)
        expect(response).to have_http_status(:redirect)
      end
    end
  end

  describe "DELETE /tests/:id" do
    let!(:test_record) { create(:test, text: text, created_by: teacher) }

    context "作成者の場合" do
      before { sign_in teacher }

      it "テストが削除される" do
        expect {
          delete test_path(test_record)
        }.to change(Test, :count).by(-1)
      end
    end

    context "作成者でない場合" do
      let(:other_teacher) { create(:user, :teacher) }
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        delete test_path(test_record)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
