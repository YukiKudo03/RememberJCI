# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "GroupMembers", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:group) { create(:group, created_by: teacher) }

  describe "POST /groups/:group_id/members" do
    context "グループ作成者の場合" do
      before { sign_in teacher }

      it "メンバーが追加される" do
        expect {
          post group_members_path(group), params: { user_id: learner.id }
        }.to change { group.members.count }.by(1)
      end

      it "グループ詳細にリダイレクトされる" do
        post group_members_path(group), params: { user_id: learner.id }
        expect(response).to redirect_to(group_path(group))
      end
    end

    context "グループ作成者でない場合" do
      let(:other_teacher) { create(:user, :teacher) }
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        post group_members_path(group), params: { user_id: learner.id }
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "DELETE /groups/:group_id/members/:id" do
    before do
      group.add_member(learner)
    end

    context "グループ作成者の場合" do
      before { sign_in teacher }

      it "メンバーが削除される" do
        membership = group.group_members.find_by(user: learner)
        expect {
          delete group_member_path(group, membership)
        }.to change { group.members.count }.by(-1)
      end
    end

    context "グループ作成者でない場合" do
      let(:other_teacher) { create(:user, :teacher) }
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        membership = group.group_members.find_by(user: learner)
        delete group_member_path(group, membership)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
