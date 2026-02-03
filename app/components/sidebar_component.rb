# frozen_string_literal: true

# SidebarComponent - サイドバーナビゲーションコンポーネント
#
# ロールに応じたナビゲーションメニューをサイドバーとして表示する。
# メインセクションと管理セクションに分かれ、アクティブ状態を表示する。
#
# @example 基本的な使用
#   <%= render SidebarComponent.new(current_user: current_user) %>
#
# @example オプション付き
#   <%= render SidebarComponent.new(
#     current_user: current_user,
#     current_path: request.path,
#     collapsible: true
#   ) %>
#
class SidebarComponent < ApplicationComponent
  # @param current_user [User] 現在のユーザー
  # @param current_path [String, nil] 現在のパス（アクティブ状態の判定用）
  # @param collapsible [Boolean] 折りたたみ可能にするかどうか
  def initialize(current_user:, current_path: nil, collapsible: false)
    @current_user = current_user
    @current_path = current_path
    @collapsible = collapsible
  end

  attr_reader :current_user

  # 折りたたみ可能かどうか
  # @return [Boolean]
  def collapsible?
    @collapsible
  end

  # メインナビゲーションアイテム
  # @return [Array<Hash>]
  def main_items
    case @current_user.role
    when "admin"
      admin_main_items
    when "teacher"
      teacher_main_items
    else
      learner_main_items
    end
  end

  # 管理セクションアイテム（管理者のみ）
  # @return [Array<Hash>]
  def admin_items
    return [] unless @current_user.admin?

    [
      { label: "ユーザー管理", path: "/admin/users", icon: :users },
      { label: "テキスト管理", path: "/admin/texts", icon: :document }
    ]
  end

  # 管理セクションがあるかどうか
  # @return [Boolean]
  def has_admin_section?
    @current_user.admin?
  end

  # アイテムがアクティブかどうか
  # @param item [Hash] ナビゲーションアイテム
  # @return [Boolean]
  def active?(item)
    return false if @current_path.nil?

    @current_path == item[:path] || @current_path.start_with?(item[:path] + "/")
  end

  # アクティブ状態のCSSクラス
  # @param item [Hash]
  # @return [String]
  def item_classes(item)
    if active?(item)
      "sidebar-item-active bg-indigo-50 text-indigo-700 border-r-2 border-indigo-600"
    else
      "text-gray-600 hover:bg-gray-50 hover:text-indigo-600"
    end
  end

  # アイコンをSVGとしてレンダリング
  # @param icon_name [Symbol] アイコン名
  # @return [String] SVG HTML
  def render_icon(icon_name)
    svg = ICONS[icon_name] || ICONS[:home]
    svg.html_safe
  end

  ICONS = {
    home: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z"/></svg>',
    book: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M9 4.804A7.968 7.968 0 005.5 4c-1.255 0-2.443.29-3.5.804v10A7.969 7.969 0 015.5 14c1.669 0 3.218.51 4.5 1.385A7.962 7.962 0 0114.5 14c1.255 0 2.443.29 3.5.804v-10A7.968 7.968 0 0014.5 4c-1.255 0-2.443.29-3.5.804V12a1 1 0 11-2 0V4.804z"/></svg>',
    chart: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z"/></svg>',
    clipboard: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M8 3a1 1 0 011-1h2a1 1 0 110 2H9a1 1 0 01-1-1z"/><path d="M6 3a2 2 0 00-2 2v11a2 2 0 002 2h8a2 2 0 002-2V5a2 2 0 00-2-2 3 3 0 01-3 3H9a3 3 0 01-3-3z"/></svg>',
    group: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M13 6a3 3 0 11-6 0 3 3 0 016 0zM18 8a2 2 0 11-4 0 2 2 0 014 0zM14 15a4 4 0 00-8 0v3h8v-3zM6 8a2 2 0 11-4 0 2 2 0 014 0zM16 18v-3a5.972 5.972 0 00-.75-2.906A3.005 3.005 0 0119 15v3h-3zM4.75 12.094A5.973 5.973 0 004 15v3H1v-3a3 3 0 013.75-2.906z"/></svg>',
    task: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" d="M6 2a2 2 0 00-2 2v12a2 2 0 002 2h8a2 2 0 002-2V7.414A2 2 0 0015.414 6L12 2.586A2 2 0 0010.586 2H6zm5 6a1 1 0 10-2 0v2H7a1 1 0 100 2h2v2a1 1 0 102 0v-2h2a1 1 0 100-2h-2V8z" clip-rule="evenodd"/></svg>',
    users: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/></svg>',
    document: '<svg class="h-5 w-5 flex-shrink-0" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true"><path fill-rule="evenodd" d="M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4zm2 6a1 1 0 011-1h6a1 1 0 110 2H7a1 1 0 01-1-1zm1 3a1 1 0 100 2h6a1 1 0 100-2H7z" clip-rule="evenodd"/></svg>'
  }.freeze

  private

  def learner_main_items
    [
      { label: "ダッシュボード", path: "/", icon: :home },
      { label: "学習", path: "/learning/texts", icon: :book },
      { label: "進捗", path: "/learning/progress", icon: :chart },
      { label: "テスト", path: "/tests", icon: :clipboard }
    ]
  end

  def teacher_main_items
    [
      { label: "ダッシュボード", path: "/", icon: :home },
      { label: "グループ", path: "/groups", icon: :group },
      { label: "テスト", path: "/tests", icon: :clipboard },
      { label: "課題", path: "/assignments", icon: :task },
      { label: "分析", path: "/analytics/groups", icon: :chart }
    ]
  end

  def admin_main_items
    [
      { label: "ダッシュボード", path: "/", icon: :home },
      { label: "グループ", path: "/groups", icon: :group },
      { label: "テスト", path: "/tests", icon: :clipboard },
      { label: "分析", path: "/analytics/groups", icon: :chart }
    ]
  end
end
