# frozen_string_literal: true

require "rails_helper"

RSpec.describe "JoinInvites (public)", type: :request do
  let(:owner)  { create(:user, :teacher, name: "山田太郎") }
  let(:group)  { create(:group, created_by: owner, name: "東京第一LOM") }
  let(:invite) { create(:group_invite, group: group, created_by: owner) }

  describe "GET /join/:token" do
    context "with a valid active invite" do
      it "renders the public show page (no auth required)" do
        get join_invite_path(token: invite.token)
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(group.name)
        expect(response.body).to include(owner.name)
      end

      it "stashes the token in session for sign-up pickup" do
        get join_invite_path(token: invite.token)
        expect(session[:pending_invite_token]).to eq(invite.token)
      end

      context "when signed in as a non-member" do
        let(:other) { create(:user) }
        before { sign_in other }

        it "still renders show (shows join-with-current CTA)" do
          get join_invite_path(token: invite.token)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("join_invites.show.join_with_current_cta"))
        end
      end

      context "when signed in as an existing member" do
        let(:existing_member) { create(:user) }
        before do
          group.add_member(existing_member)
          sign_in existing_member
        end

        it "renders the already-member branch" do
          get join_invite_path(token: invite.token)
          expect(response).to have_http_status(:ok)
          expect(response.body).to include(I18n.t("join_invites.show.already_member_title"))
        end
      end
    end

    context "with an invalid / expired / revoked / exhausted token" do
      it "returns 404 for unknown token" do
        get join_invite_path(token: "nonexistent_token_value_deadbeef")
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include(I18n.t("join_invites.invalid.title"))
      end

      it "returns 404 for expired invite" do
        expired = create(:group_invite, :expired, group: group, created_by: owner)
        get join_invite_path(token: expired.token)
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include(I18n.t("join_invites.invalid.title"))
      end

      it "returns 404 for revoked invite" do
        revoked = create(:group_invite, :revoked, group: group, created_by: owner)
        get join_invite_path(token: revoked.token)
        expect(response).to have_http_status(:not_found)
      end

      it "returns 404 for exhausted invite" do
        exhausted = create(:group_invite, :exhausted, group: group, created_by: owner)
        get join_invite_path(token: exhausted.token)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /join/:token" do
    context "when signed in (not a member)" do
      let(:joiner) { create(:user) }
      before { sign_in joiner }

      it "consumes the invite, adds the user to the group, and redirects" do
        expect {
          post accept_join_invite_path(token: invite.token)
        }.to change { invite.reload.uses_count }.by(1)
          .and change { group.reload.members.count }.by(1)

        expect(group.members).to include(joiner)
        expect(response).to redirect_to(root_path)
      end

      it "is idempotent: existing member sees already-member notice and no double consume" do
        group.add_member(joiner)
        expect {
          post accept_join_invite_path(token: invite.token)
        }.not_to change { invite.reload.uses_count }

        expect(response).to redirect_to(root_path)
      end
    end

    context "when not signed in" do
      it "stashes token in session and redirects to sign-up" do
        post accept_join_invite_path(token: invite.token)
        expect(session[:pending_invite_token]).to eq(invite.token)
        expect(response).to redirect_to(new_user_registration_path)
      end
    end

    context "when the invite became inactive between show and accept (race loss)" do
      let(:joiner) { create(:user) }
      before { sign_in joiner }

      it "returns 410 Gone with the invalid page" do
        # Simulate a race by revoking the invite after initial validation.
        # set_invite runs GroupInvite.active.find_by which will reject revoked
        # tokens up front, so we stage a live invite then revoke right before
        # consume! by monkey-patching set_invite's lookup via direct revocation
        # between lookup and consume. The simplest realistic scenario is an
        # exhausted invite that somehow passes set_invite, which can't happen
        # with find_by(active scope), so we exercise consume!'s race path by
        # calling .update_columns to bypass set_invite guard.

        # Take the existing active invite, exhaust it via a direct SQL update
        # that set_invite cannot see without a reload, then POST accept. In
        # practice the controller reloads on every request, so the only true
        # race window is between set_invite and consume!. We simulate that by
        # calling destroy-like state mutation after set_invite would run. Since
        # we can't hook into the controller mid-action easily in a request
        # spec, instead exercise the consume! race guard at the model layer
        # (already covered in the model spec), and here verify the 410
        # response path by mocking consume! to return false.
        allow_any_instance_of(GroupInvite).to receive(:consume!).and_return(false)

        post accept_join_invite_path(token: invite.token)
        expect(response).to have_http_status(:gone)
        expect(response.body).to include(I18n.t("join_invites.invalid.title"))
      end
    end

    context "with an invalid/expired token" do
      it "returns 404 for unknown token" do
        post accept_join_invite_path(token: "nonexistent_token_value_deadbeef")
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
