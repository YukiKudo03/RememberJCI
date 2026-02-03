# frozen_string_literal: true

# テスト管理コントローラー
# テストの作成、受験、提出、結果表示を担当
class TestsController < ApplicationController
  before_action :set_test, only: [:destroy, :take, :submit, :result]

  # Pundit認可エラー時のハンドリング
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # GET /tests
  # テスト一覧を表示（教師は自分のテスト、管理者は全テスト）
  def index
    authorize Test
    @tests = policy_scope(Test).includes(:text, :created_by)
  end

  # GET /tests/new
  # 新規テスト作成フォームを表示
  def new
    authorize Test
    @test = Test.new
  end

  # POST /tests
  # テストを作成
  def create
    authorize Test
    @test = Test.new(test_params)
    @test.created_by = current_user

    if @test.save
      redirect_to tests_path, notice: "テストを作成しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /tests/:id
  # テストを削除
  def destroy
    authorize @test
    @test.destroy
    redirect_to tests_path, notice: "テストを削除しました"
  end

  # GET /tests/:id/take
  # テスト受験画面を表示
  def take
    authorize @test

    # テストが利用可能期間外の場合はアクセス拒否
    unless @test.available?
      raise Pundit::NotAuthorizedError, "このテストは現在利用できません"
    end
  end

  # POST /tests/:id/submit
  # テストの回答を提出
  def submit
    authorize @test

    @submission = @test.submissions.build(submission_params)
    @submission.user = current_user

    if @submission.save
      # 自動採点を実行
      Testing::ScoringService.new(submission: @submission).grade!
      redirect_to result_test_path(@test)
    else
      render :take, status: :unprocessable_entity
    end
  end

  # GET /tests/:id/result
  # テスト結果を表示
  def result
    authorize @test

    @submission = @test.submissions.find_by(user: current_user)

    # 提出がない場合はテスト一覧へリダイレクト
    unless @submission
      redirect_to tests_path, alert: "まだテストを提出していません"
      return
    end
  end

  private

  # テストをパラメータから取得
  def set_test
    @test = Test.find(params[:id])
  end

  # テスト作成用のストロングパラメータ
  def test_params
    params.require(:test).permit(:title, :text_id, :test_type, :time_limit, :available_from, :available_until)
  end

  # 提出用のストロングパラメータ
  def submission_params
    params.require(:submission).permit(:submitted_text)
  end

  # 認可エラー時のハンドリング
  def user_not_authorized
    render plain: "Forbidden", status: :forbidden
  end
end
