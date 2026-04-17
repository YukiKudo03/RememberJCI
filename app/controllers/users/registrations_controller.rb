# frozen_string_literal: true

# Devise registration override. Two behaviors:
#
#   1. Normal sign-up (no invite token in session): unchanged — Devise's default
#      :confirmable flow emails a confirmation link and bounces the user to
#      sign-in until they click it.
#
#   2. Invite-scoped sign-up (session[:pending_invite_token] present and the
#      invite is still active):
#        - skip_confirmation! is called in build_resource BEFORE save, so
#          confirmed_at is set in the same INSERT as the user row. No
#          confirmation email is sent and the user is signed in immediately.
#        - after save, the create action yields resource to a block. Inside
#          that block (user is saved and signed in), we consume the invite
#          and create the membership atomically, so sign-up → group member
#          → dashboard happens in a single request.
#        - session[:pending_invite_token] is cleared on success or stale.
#
# Rationale: a POST redirect into JoinInvitesController#accept is not possible
# (redirects are GET), and forcing the user to click a confirm button after
# sign-up adds a step for no safety gain — they proved intent by going through
# the whole sign-up flow from the invite URL.
class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |resource|
      next unless resource.persisted?
      next unless session[:pending_invite_token].present?
      consume_pending_invite_for(resource)
    end
  end

  protected

  def build_resource(hash = nil)
    super
    resource.skip_confirmation! if pending_invite_active?
  end

  def after_inactive_sign_up_path_for(_resource)
    new_user_session_path
  end

  private

  def pending_invite_active?
    token = session[:pending_invite_token]
    return false if token.blank?
    GroupInvite.active.exists?(token: token)
  end

  # Called after `super` has saved the resource. If the invite is still active
  # (race guard: it could have been revoked/exhausted during the sign-up form
  # submission), consume it atomically and create the membership.
  #
  # Wraps consume + add_member in a transaction with a row lock so that
  # partial failures (add_member blowing up after consume) roll back the
  # invite use, and concurrent sign-ups can't double-consume the same invite.
  # Note: the user record is already saved by `super` outside this transaction,
  # which is a known limitation — if the invite just became inactive, the user
  # is still confirmed via skip_confirmation!. Acceptable for JCI-internal use.
  def consume_pending_invite_for(user)
    token = session.delete(:pending_invite_token)
    return if token.blank?

    GroupInvite.transaction do
      invite = GroupInvite.lock.find_by(token: token)
      return unless invite&.active?

      if invite.consume!
        invite.group.add_member(user)
        flash[:notice] = I18n.t("join_invites.notices.joined", group: invite.group.name)
      end
    end
  end
end
