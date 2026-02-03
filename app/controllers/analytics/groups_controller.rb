# frozen_string_literal: true

module Analytics
  # グループ分析コントローラー
  # 教師がグループの学習進捗を確認するための機能を提供
  #
  # 要件参照: FR-62（教師はグループレベルの分析を確認できる）
  # 要件参照: US-T01（グループ進捗確認）
  #
  class GroupsController < ApplicationController
    skip_after_action :verify_authorized, only: [:show, :member]
    skip_after_action :verify_policy_scoped

    before_action :set_group, only: [:show, :member]
    before_action :authorize_group_access, only: [:show, :member]

    # Pundit認可エラー時のハンドリング
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # GET /analytics/groups
    # グループ一覧（分析対象）を表示
    def index
      authorize Group, :index?

      @groups = if current_user.admin?
                  Group.includes(:members, :created_by).all
                else
                  Group.includes(:members, :created_by).where(created_by: current_user)
                end
    end

    # GET /analytics/groups/:id
    # グループの分析詳細を表示
    def show
      @members = @group.members.includes(:learning_progresses, :test_submissions)
      @member_analytics = build_member_analytics(@members)
    end

    # GET /analytics/groups/:id/members/:member_id
    # 特定メンバーの詳細分析を表示
    def member
      @member = @group.members.find(params[:member_id])
      @learning_progresses = @member.learning_progresses.includes(:text)
      @test_submissions = @member.test_submissions.includes(test: :text)
    end

    private

    # グループをパラメータから取得
    def set_group
      @group = Group.find(params[:id])
    end

    # グループへのアクセス権限を確認
    def authorize_group_access
      unless current_user.admin? || @group.created_by_id == current_user.id
        raise Pundit::NotAuthorizedError
      end
    end

    # メンバーごとの分析データを構築
    def build_member_analytics(members)
      members.map do |member|
        {
          user: member,
          progress_percentage: calculate_progress_percentage(member),
          latest_test_score: latest_test_score(member),
          texts_mastered: texts_mastered_count(member),
          total_time_spent: total_time_spent(member),
          is_behind: behind_schedule?(member)
        }
      end
    end

    # 進捗率を計算（全テキストの平均）
    def calculate_progress_percentage(member)
      progresses = member.learning_progresses
      return 0 if progresses.empty?

      total = progresses.sum { |p| p.completion_percentage }
      (total.to_f / progresses.count).round
    end

    # 最新のテストスコアを取得
    def latest_test_score(member)
      submission = member.test_submissions.order(created_at: :desc).first
      submission&.final_score
    end

    # マスターしたテキスト数を取得
    def texts_mastered_count(member)
      member.learning_progresses.count(&:mastered?)
    end

    # 総学習時間を取得（秒）
    def total_time_spent(member)
      member.learning_progresses.sum(:total_study_time)
    end

    # 予定より遅れているかどうか
    # 簡易的に：7日以上進捗がない場合を「遅れ」とする
    def behind_schedule?(member)
      latest_progress = member.learning_progresses.order(updated_at: :desc).first
      return false unless latest_progress

      latest_progress.updated_at < 7.days.ago
    end

    # 認可エラー時のハンドリング
    def user_not_authorized
      render plain: "Forbidden", status: :forbidden
    end
  end
end
