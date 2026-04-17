# frozen_string_literal: true

require "rails_helper"

RSpec.describe "GroupInvites (admin CRUD)", type: :request do
  let(:owner) { create(:user, :teacher) }
  let(:group) { create(:group, created_by: owner) }

  describe "GET /groups/:group_id/invites" do
    before { sign_in owner }

    it "shows the invite list" do
      invite = create(:group_invite, group: group, created_by: owner)
      get group_invites_path(group)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(invite.token)
    end

    it "renders empty state when no invites exist" do
      get group_invites_path(group)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t("group_invites.index.empty_title"))
    end

    context "as an unrelated teacher" do
      let(:other) { create(:user, :teacher) }
      before { sign_out owner; sign_in other }

      it "is forbidden" do
        get group_invites_path(group)
        expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
      end
    end

    context "when not signed in" do
      before { sign_out owner }
      it "redirects to login" do
        get group_invites_path(group)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /groups/:group_id/invites" do
    before { sign_in owner }

    it "creates an invite with form params" do
      expect {
        post group_invites_path(group), params: {
          group_invite: { max_uses: 15, expires_at: 10.days.from_now }
        }
      }.to change(GroupInvite, :count).by(1)

      invite = GroupInvite.last
      expect(invite.max_uses).to eq(15)
      expect(invite.created_by).to eq(owner)
      expect(invite.token.length).to eq(32)
      expect(response).to redirect_to(group_invites_path(group))
    end

    it "re-renders :new with errors on invalid params" do
      post group_invites_path(group), params: {
        group_invite: { max_uses: 0, expires_at: 10.days.from_now }
      }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include(I18n.t("group_invites.errors.create_failed"))
    end
  end

  describe "DELETE /groups/:group_id/invites/:id" do
    let!(:invite) { create(:group_invite, group: group, created_by: owner) }

    it "soft-deletes the invite (sets revoked_at)" do
      sign_in owner
      expect {
        delete group_invite_path(group, invite)
      }.to change { invite.reload.revoked_at }.from(nil)

      expect(invite.reload).to be_revoked
      expect(GroupInvite.exists?(invite.id)).to be(true) # still in DB
      expect(response).to redirect_to(group_invites_path(group))
    end

    it "unrelated teacher cannot revoke" do
      other = create(:user, :teacher)
      sign_in other
      expect {
        delete group_invite_path(group, invite)
      }.not_to change { invite.reload.revoked_at }
    end
  end
end
