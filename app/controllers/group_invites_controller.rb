# frozen_string_literal: true

# Admin-side invite management. All actions here require authentication and
# authorization through Pundit (inherited from ApplicationController).
#
# Public token-based actions (show/accept) live in JoinInvitesController —
# different trust zone, different controller.
#
#   Request flow (create):
#
#     POST /groups/:group_id/invites
#       │
#       └─► authorize @group against GroupInvitePolicy#create?
#             │
#             └─► build with created_by: current_user + form params
#                   │
#                   └─► save ─► redirect with flash, has_secure_token
#                                sets :token automatically on create.
class GroupInvitesController < ApplicationController
  before_action :set_group
  before_action :set_invite, only: [:destroy]

  def index
    authorize @group, policy_class: GroupInvitePolicy
    # Scope via policy_scope so the after_action :verify_policy_scoped passes,
    # then restrict to this group. Result is equivalent to @group.invites with
    # Pundit discipline enforced.
    @invites = policy_scope(GroupInvite).where(group_id: @group.id)
                                        .includes(:created_by)
                                        .order(created_at: :desc)
  end

  def new
    authorize @group, policy_class: GroupInvitePolicy
    @invite = @group.invites.build(default_invite_attributes)
  end

  def create
    authorize @group, policy_class: GroupInvitePolicy
    @invite = @group.invites.build(invite_params.merge(created_by: current_user))

    if @invite.save
      redirect_to group_invites_path(@group), notice: t("group_invites.notices.created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @invite
    @invite.revoke!
    redirect_to group_invites_path(@group), notice: t("group_invites.notices.revoked")
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def set_invite
    @invite = @group.invites.find(params[:id])
  end

  def invite_params
    params.require(:group_invite).permit(:max_uses, :expires_at)
  end

  def default_invite_attributes
    { max_uses: 10, expires_at: 7.days.from_now }
  end
end
