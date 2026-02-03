# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Submissions", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:other_teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: admin) }
  let(:test_record) { create(:test, text: text, created_by: teacher) }
  let!(:submission) { create(:test_submission, :auto_graded, test: test_record, user: learner) }

  describe "GET /tests/:test_id/submissions" do
    context "テスト作成者（教師）の場合" do
      before { sign_in teacher }

      it "成功する" do
        get test_submissions_path(test_record)
        expect(response).to have_http_status(:success)
      end

      it "提出一覧が表示される" do
        get test_submissions_path(test_record)
        expect(response.body).to include(learner.name)
      end

      it "スコアが表示される" do
        get test_submissions_path(test_record)
        expect(response.body).to include(submission.auto_score.to_s)
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get test_submissions_path(test_record)
        expect(response).to have_http_status(:success)
      end
    end

    context "別の教師の場合" do
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        get test_submissions_path(test_record)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        get test_submissions_path(test_record)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "GET /tests/:test_id/submissions/:id" do
    context "テスト作成者（教師）の場合" do
      before { sign_in teacher }

      it "成功する" do
        get test_submission_path(test_record, submission)
        expect(response).to have_http_status(:success)
      end

      it "提出内容が表示される" do
        get test_submission_path(test_record, submission)
        expect(response.body).to include(submission.submitted_text)
      end

      it "スコアが表示される" do
        get test_submission_path(test_record, submission)
        expect(response.body).to include(submission.auto_score.to_s)
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get test_submission_path(test_record, submission)
        expect(response).to have_http_status(:success)
      end
    end

    context "別の教師の場合" do
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        get test_submission_path(test_record, submission)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "PATCH /tests/:test_id/submissions/:id" do
    let(:grade_params) do
      {
        submission: {
          manual_score: 85,
          feedback: "よくできました"
        }
      }
    end

    context "テスト作成者（教師）の場合" do
      before { sign_in teacher }

      it "手動スコアを更新できる" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(submission.reload.manual_score).to eq(85)
      end

      it "フィードバックを更新できる" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(submission.reload.feedback).to eq("よくできました")
      end

      it "ステータスがmanually_gradedに更新される" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(submission.reload.status).to eq("manually_graded")
      end

      it "提出物詳細にリダイレクトされる" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(response).to redirect_to(test_submission_path(test_record, submission))
      end

      it "採点完了通知メールが送信される" do
        expect {
          patch test_submission_path(test_record, submission), params: grade_params
        }.to have_enqueued_mail(GradingMailer, :graded)
      end
    end

    context "管理者の場合" do
      before { sign_in admin }

      it "手動スコアを更新できる" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(submission.reload.manual_score).to eq(85)
      end
    end

    context "別の教師の場合" do
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(response).to have_http_status(:forbidden)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        patch test_submission_path(test_record, submission), params: grade_params
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "提出がないテストの場合" do
    let(:empty_test) { create(:test, text: text, created_by: teacher) }

    context "テスト作成者の場合" do
      before { sign_in teacher }

      it "提出一覧は空で表示される" do
        get test_submissions_path(empty_test)
        expect(response).to have_http_status(:success)
        expect(response.body).to include("提出がありません")
      end
    end
  end
end
