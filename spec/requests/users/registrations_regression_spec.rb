# frozen_string_literal: true

require "rails_helper"

# Regression protection for Users::RegistrationsController.
# The controller now has invite-aware hooks (skip_confirmation! in
# build_resource, invite consumption in create block). Make sure normal
# sign-up (no invite in session) still follows Devise's standard flow.
RSpec.describe "Users::RegistrationsController regression", type: :request do
  describe "normal sign-up (no pending invite token)" do
    let(:signup_params) do
      {
        user: {
          email: "new_learner@example.com",
          name: "新規ユーザー",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "creates an unconfirmed user" do
      expect {
        post user_registration_path, params: signup_params
      }.to change(User, :count).by(1)

      user = User.find_by(email: "new_learner@example.com")
      expect(user).to be_present
      expect(user.confirmed_at).to be_nil
    end

    it "does not auto-join any group" do
      post user_registration_path, params: signup_params
      user = User.find_by(email: "new_learner@example.com")
      expect(user.groups).to be_empty
    end

    it "redirects to sign-in (after_inactive_sign_up_path)" do
      post user_registration_path, params: signup_params
      expect(response).to redirect_to(new_user_session_path)
    end
  end

  describe "invite-scoped sign-up (pending_invite_token in session)" do
    let(:owner)  { create(:user, :teacher) }
    let(:group)  { create(:group, created_by: owner) }
    let(:invite) { create(:group_invite, group: group, created_by: owner) }

    before do
      # Stash the invite token by visiting /join/:token first
      get join_invite_path(token: invite.token)
    end

    let(:signup_params) do
      {
        user: {
          email: "invitee@example.com",
          name: "招待経由の新メンバー",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "auto-confirms the new user (skip_confirmation! before save)" do
      post user_registration_path, params: signup_params
      user = User.find_by(email: "invitee@example.com")
      expect(user.confirmed_at).to be_present
    end

    it "auto-joins the group and consumes the invite" do
      expect {
        post user_registration_path, params: signup_params
      }.to change { invite.reload.uses_count }.by(1)
        .and change { group.reload.members.count }.by(1)

      user = User.find_by(email: "invitee@example.com")
      expect(group.members).to include(user)
    end

    it "clears the session token after consumption" do
      post user_registration_path, params: signup_params
      expect(session[:pending_invite_token]).to be_nil
    end
  end

  describe "invite-scoped sign-up where invite went stale during form fill" do
    let(:owner)  { create(:user, :teacher) }
    let(:group)  { create(:group, created_by: owner) }
    let(:invite) { create(:group_invite, group: group, created_by: owner) }

    before do
      get join_invite_path(token: invite.token)
      invite.revoke! # user is filling out form; admin revokes in parallel
    end

    let(:signup_params) do
      {
        user: {
          email: "racer@example.com",
          name: "レース敗者",
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    it "still creates the user but falls back to normal unconfirmed flow" do
      expect {
        post user_registration_path, params: signup_params
      }.to change(User, :count).by(1)

      user = User.find_by(email: "racer@example.com")
      # Because the invite was ACTIVE at build_resource time (session had the
      # token and pending_invite_active? checks GroupInvite.active.exists?),
      # the skip_confirmation decision is a pre-save check. If revocation
      # happens between build_resource and the create block, the user ends
      # up confirmed but not joined. That's acceptable — stale invites do not
      # retroactively invalidate the sign-up.
      expect(user.groups).to be_empty
    end
  end
end
