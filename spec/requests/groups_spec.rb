# spec/requests/groups_spec.rb
require 'rails_helper'

RSpec.describe "Groups", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }

  describe "GET /groups" do
    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get groups_path
        expect(response).to have_http_status(:success)
      end

      it "全グループが表示される" do
        group = create(:group, created_by: teacher)
        get groups_path
        expect(response.body).to include(group.name)
      end
    end

    context "教師の場合" do
      before { sign_in teacher }

      it "成功する" do
        get groups_path
        expect(response).to have_http_status(:success)
      end

      it "自分が作成したグループのみ表示される" do
        own_group = create(:group, created_by: teacher)
        other_group = create(:group, created_by: admin)
        get groups_path
        expect(response.body).to include(own_group.name)
        expect(response.body).not_to include(other_group.name)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        get groups_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /groups" do
    context "管理者または教師の場合" do
      before { sign_in teacher }

      let(:valid_params) do
        { group: { name: "新規グループ", description: "説明文" } }
      end

      it "グループが作成される" do
        expect {
          post groups_path, params: valid_params
        }.to change(Group, :count).by(1)
      end

      it "作成者が設定される" do
        post groups_path, params: valid_params
        expect(Group.last.created_by).to eq(teacher)
      end
    end
  end

  describe "GET /groups/:id" do
    let(:group) { create(:group, created_by: teacher) }

    context "教師が自分のグループを閲覧する場合" do
      before { sign_in teacher }

      it "成功する" do
        get group_path(group)
        expect(response).to have_http_status(:success)
      end

      it "メンバー一覧が表示される" do
        member = create(:user, :learner)
        group.add_member(member)
        get group_path(group)
        expect(response.body).to include(member.name)
      end
    end
  end
end
