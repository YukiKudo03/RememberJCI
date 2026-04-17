# frozen_string_literal: true

# Authorization for GroupInvite admin actions (index / new / create / destroy).
# Public token-based actions (show / accept) live on JoinInvitesController and
# use the token itself as the capability — they don't flow through Pundit.
#
# Only the group's `created_by` user (the LOM organizer) and admins can manage
# invites. This mirrors GroupPolicy's ownership check (`owner?`).
class GroupInvitePolicy < ApplicationPolicy
  def index?
    user.admin? || owner?
  end

  def new?
    user.admin? || owner?
  end

  def create?
    user.admin? || owner?
  end

  def destroy?
    user.admin? || owner?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin?
        scope.all
      else
        scope.joins(:group).where(groups: { created_by_id: user.id })
      end
    end
  end

  private

  # `record` is either a GroupInvite instance or (for new/create where no
  # invite exists yet) a Group instance passed in explicitly by the controller.
  def owner?
    group = record.is_a?(Group) ? record : record.group
    group.created_by_id == user.id
  end
end
