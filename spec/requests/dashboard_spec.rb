# spec/requests/dashboard_spec.rb
require 'rails_helper'

RSpec.describe "Dashboard", type: :request do
  describe "GET /" do
    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get root_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "学習者としてログインしている場合" do
      let(:user) { create(:user, :learner) }
      before { sign_in user }

      it "成功する" do
        get root_path
        expect(response).to have_http_status(:success)
      end

      it "アサインされたテキストが表示される" do
        assignment = create(:assignment, :to_user, user: user)
        get root_path
        expect(response.body).to include(assignment.text.title)
      end
    end

    context "教師としてログインしている場合" do
      let(:user) { create(:user, :teacher) }
      before { sign_in user }

      it "担当グループが表示される" do
        group = create(:group, created_by: user)
        get root_path
        expect(response.body).to include(group.name)
      end
    end

    context "管理者としてログインしている場合" do
      let(:user) { create(:user, :admin) }
      before { sign_in user }

      it "全体統計が表示される" do
        get root_path
        expect(response.body).to include("全体統計")
      end
    end
  end
end
