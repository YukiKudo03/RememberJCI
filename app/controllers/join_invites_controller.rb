# frozen_string_literal: true

# Public-facing invite acceptance. Token-scoped capability — the URL token is
# the authorization, so this bypasses the app's auth/pundit defaults.
#
#   /join/:token  GET  → show (branch on auth state + membership state)
#   /join/:token  POST → accept (consume invite, create membership, redirect)
#
# Four UI branches for show:
#
#   unauthenticated  → invite summary + sign-up CTA
#                      (session stashes token, RegistrationsController
#                       auto-confirms + accepts after sign-up)
#   logged-in, same  → "use this account" confirm button + switch-account link
#   logged-in, member→ "already a member" + link to group
#   invalid/expired  → unified 404-like page
#
# The invalid/expired/revoked/exhausted branches all surface the same message
# on purpose: we don't want to leak which of the four failed (token oracle).
class JoinInvitesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :accept]
  skip_after_action :verify_authorized, only: [:show, :accept]
  skip_after_action :verify_policy_scoped, only: [:show, :accept]

  before_action :set_invite, only: [:show, :accept]

  def show
    # Stash the token in the session so Users::RegistrationsController#build_resource
    # can pick it up and auto-confirm the new user + accept the invite.
    session[:pending_invite_token] = @invite.token
    @already_member = user_signed_in? && @invite.group.members.include?(current_user)
  end

  def accept
    unless user_signed_in?
      # Should not reach here in the normal flow (sign-up consumes via session),
      # but if a logged-out user POSTs directly, bounce to sign-up.
      session[:pending_invite_token] = @invite.token
      return redirect_to new_user_registration_path
    end

    joined = false

    # Single transaction for consume + add_member so partial failures (e.g.
    # add_member blows up mid-flight) roll back the consume and do not burn
    # an invite use. Lock the invite row so a double-submit from the same
    # user (or two users racing on a max_uses=1 invite) serialize.
    GroupInvite.transaction do
      @invite.lock!

      if @invite.group.members.include?(current_user)
        # Already a member — no consume, no double-increment.
        joined = :already_member
        next
      end

      if @invite.consume!
        @invite.group.add_member(current_user)
        joined = true
      end
    end

    session.delete(:pending_invite_token)

    case joined
    when :already_member
      redirect_to root_path, notice: t("join_invites.notices.already_member")
    when true
      redirect_to root_path, notice: t("join_invites.notices.joined", group: @invite.group.name)
    else
      # Race lost: invite became inactive between show and accept.
      render :invalid, status: :gone
    end
  end

  private

  def set_invite
    @invite = GroupInvite.active.find_by(token: params[:token])
    render :invalid, status: :not_found if @invite.nil?
  end
end
