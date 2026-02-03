module ApplicationHelper
  # =============================================================================
  # Navigation Helpers
  # =============================================================================

  # Returns navigation menu items based on user role
  # @param role [String, Symbol] The user's role (learner, teacher, admin)
  # @return [Array<Hash>] Array of navigation items with :label and :path keys
  def navigation_items_for_role(role)
    case role.to_s
    when "admin"
      [
        { label: "ダッシュボード", path: root_path },
        { label: "ユーザー管理", path: "#" }, # TODO: Update when route is available
        { label: "テキスト管理", path: "#" }, # TODO: Update when route is available
        { label: "グループ管理", path: "#" }  # TODO: Update when route is available
      ]
    when "teacher"
      [
        { label: "ダッシュボード", path: root_path },
        { label: "グループ管理", path: "#" }, # TODO: Update when route is available
        { label: "テスト管理", path: "#" }    # TODO: Update when route is available
      ]
    else # learner
      [
        { label: "ダッシュボード", path: root_path },
        { label: "学習", path: "#" },         # TODO: Update when route is available
        { label: "テスト", path: "#" }        # TODO: Update when route is available
      ]
    end
  end

  # Returns CSS classes for role badge styling
  # @param role [String, Symbol] The user's role
  # @return [String] Tailwind CSS classes for the badge
  def role_badge_class(role)
    case role.to_s
    when "admin"
      "bg-purple-100 text-purple-800"
    when "teacher"
      "bg-blue-100 text-blue-800"
    else # learner
      "bg-green-100 text-green-800"
    end
  end

  # Returns Japanese display name for role
  # @param role [String, Symbol] The user's role
  # @return [String] Japanese role name
  def role_display_name(role)
    case role.to_s
    when "admin"
      "管理者"
    when "teacher"
      "教師"
    else # learner
      "学習者"
    end
  end
end
