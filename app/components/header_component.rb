# frozen_string_literal: true

# HeaderComponent - 共通ヘッダーコンポーネント
#
# アプリケーションの共通ヘッダーを表示するコンポーネント。
# ナビゲーション、ユーザー情報、モバイルメニューを含む。
#
# @example 基本的な使用（未ログイン）
#   <%= render HeaderComponent.new %>
#
# @example ログイン時
#   <%= render HeaderComponent.new(current_user: current_user) %>
#
# @example オプション付き
#   <%= render HeaderComponent.new(
#     current_user: current_user,
#     sticky: true,
#     class_name: "custom-header"
#   ) %>
#
class HeaderComponent < ApplicationComponent
  # @param current_user [User, nil] 現在のユーザー（nilの場合はゲスト）
  # @param sticky [Boolean] スティッキーヘッダーにするかどうか
  # @param class_name [String, nil] 追加のCSSクラス
  def initialize(current_user: nil, sticky: true, class_name: nil)
    @current_user = current_user
    @sticky = sticky
    @class_name = class_name
  end

  # ユーザーがログインしているかどうか
  # @return [Boolean]
  def signed_in?
    @current_user.present?
  end

  # 現在のユーザー
  # @return [User, nil]
  attr_reader :current_user

  # スティッキーヘッダーかどうか
  # @return [Boolean]
  def sticky?
    @sticky
  end

  # ヘッダーのCSSクラス
  # @return [String]
  def header_classes
    classes = [ "bg-white", "shadow-sm", "border-b", "border-gray-200", "z-50" ]
    classes << "sticky top-0" if sticky?
    classes << @class_name if @class_name.present?
    classes.join(" ")
  end

  # ロールに応じたナビゲーションアイテム
  # @return [Array<Hash>]
  def navigation_items
    return [] unless signed_in?

    case @current_user.role
    when "admin"
      admin_navigation
    when "teacher"
      teacher_navigation
    else
      learner_navigation
    end
  end

  # ロール表示名
  # @return [String]
  def role_display_name
    return "" unless signed_in?

    case @current_user.role
    when "admin" then "管理者"
    when "teacher" then "教師"
    else "学習者"
    end
  end

  # ロールバッジのCSSクラス
  # @return [String]
  def role_badge_classes
    return "" unless signed_in?

    case @current_user.role
    when "admin"
      "bg-red-100 text-red-800"
    when "teacher"
      "bg-blue-100 text-blue-800"
    else
      "bg-green-100 text-green-800"
    end
  end

  private

  def admin_navigation
    [
      { label: "ダッシュボード", path: "/" },
      { label: "ユーザー管理", path: "/admin/users" },
      { label: "テキスト管理", path: "/admin/texts" },
      { label: "グループ", path: "/groups" },
      { label: "テスト", path: "/tests" },
      { label: "分析", path: "/analytics/groups" }
    ]
  end

  def teacher_navigation
    [
      { label: "ダッシュボード", path: "/" },
      { label: "グループ", path: "/groups" },
      { label: "テスト", path: "/tests" },
      { label: "課題", path: "/assignments" },
      { label: "分析", path: "/analytics/groups" }
    ]
  end

  def learner_navigation
    [
      { label: "ダッシュボード", path: "/" },
      { label: "学習", path: "/learning/texts" },
      { label: "進捗", path: "/learning/progress" },
      { label: "テスト", path: "/tests" }
    ]
  end
end
