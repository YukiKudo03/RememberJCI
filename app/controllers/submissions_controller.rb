# frozen_string_literal: true

# 提出物管理コントローラー
# 教師がテストの提出物を確認・採点するための機能を提供
#
# 要件参照: US-T03（成績評価）
#
class SubmissionsController < ApplicationController
  skip_after_action :verify_policy_scoped

  before_action :set_test
  before_action :set_submission, only: [:show, :update]

  # Pundit認可エラー時のハンドリング
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /tests/:test_id/submissions
  # 提出物一覧を表示
  def index
    # テストに対する認可チェック（作成者のみ閲覧可能）
    authorize @test, :show?
    @submissions = @test.submissions.includes(:user)
  end

  # GET /tests/:test_id/submissions/:id
  # 提出物詳細を表示
  def show
    authorize @submission
    # 差分情報を取得
    @scoring_service = Testing::ScoringService.new(submission: @submission)
    @diff = @scoring_service.diff
  end

  # PATCH /tests/:test_id/submissions/:id
  # 提出物を採点（手動スコア・フィードバックを更新）
  def update
    authorize @submission

    if @submission.update(submission_params)
      # 手動スコアが設定された場合、ステータスを更新
      if @submission.manual_score.present?
        @submission.update(status: :manually_graded)
        GradingMailer.graded(@submission).deliver_later
      end

      redirect_to test_submission_path(@test, @submission), notice: "採点を保存しました"
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  # テストをパラメータから取得
  def set_test
    @test = Test.find(params[:test_id])
  end

  # 提出物をパラメータから取得
  def set_submission
    @submission = @test.submissions.find(params[:id])
  end

  # 採点用のストロングパラメータ
  def submission_params
    params.require(:submission).permit(:manual_score, :feedback)
  end

  # 認可エラー時のハンドリング
  def user_not_authorized
    render plain: "Forbidden", status: :forbidden
  end
end
