# frozen_string_literal: true

class TestPolicy < ApplicationPolicy
  # 管理者と教師はテスト一覧を表示できる
  def index?
    user.admin? || user.teacher?
  end

  # 管理者と作成者はテスト詳細を表示できる
  def show?
    user.admin? || owner?
  end

  # 管理者と教師は新規テストを作成できる
  def new?
    user.admin? || user.teacher?
  end

  # 管理者と教師はテストを作成できる
  def create?
    user.admin? || user.teacher?
  end

  # 管理者と作成者はテストを削除できる
  def destroy?
    user.admin? || owner?
  end

  # テストを受験できる
  # - 管理者: 常に可能
  # - 教師（作成者）: 常に可能
  # - 学習者: テキストがアサインされている場合のみ
  def take?
    return true if user.admin? || owner?
    return false unless user.learner?

    text_assigned_to_user?
  end

  # テストを提出できる（takeと同じ条件）
  def submit?
    take?
  end

  # テスト結果を表示できる
  # - 管理者: 常に可能
  # - 教師（作成者）: 常に可能
  # - 学習者: 常に可能（提出の有無はコントローラーで確認）
  def result?
    user.admin? || owner? || user.learner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.teacher?
        scope.where(created_by: user)
      else
        scope.none
      end
    end
  end

  private

  # テスト作成者かどうか
  def owner?
    record.created_by_id == user.id
  end

  # テキストがユーザーにアサインされているか
  def text_assigned_to_user?
    return false unless record.text.present?

    Assignment.exists?(text: record.text, user: user) ||
      Assignment.joins(:group)
                .where(text: record.text)
                .where(groups: { id: user.groups.select(:id) })
                .exists?
  end
end
