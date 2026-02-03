# frozen_string_literal: true

# TestSubmissionPolicy - テスト提出物の認可ポリシー
#
# 要件参照: US-T03（成績評価）
#
class TestSubmissionPolicy < ApplicationPolicy
  # 提出物一覧を表示できるか
  # - 管理者: 常に可能
  # - 教師（テスト作成者）: 自分のテストの提出物のみ
  def index?
    user.admin? || test_owner?
  end

  # 提出物詳細を表示できるか
  def show?
    user.admin? || test_owner?
  end

  # 提出物を採点（更新）できるか
  def update?
    user.admin? || test_owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      elsif user.teacher?
        scope.joins(:test).where(tests: { created_by_id: user.id })
      else
        scope.none
      end
    end
  end

  private

  # 現在のユーザーがテストの作成者かどうか
  def test_owner?
    record.test.created_by_id == user.id
  end
end
