# spec/requests/assignments_spec.rb
require 'rails_helper'

RSpec.describe "Assignments", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: admin) }
  let(:group) { create(:group, created_by: teacher) }

  describe "GET /assignments" do
    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get assignments_path
        expect(response).to have_http_status(:success)
      end

      it "全アサインメントが表示される" do
        assignment = create(:assignment, :to_group, group: group, text: text, assigned_by: teacher)
        get assignments_path
        expect(response.body).to include(text.title)
      end
    end

    context "教師の場合" do
      before { sign_in teacher }

      it "成功する" do
        get assignments_path
        expect(response).to have_http_status(:success)
      end

      it "自分が作成したアサインメントのみ表示される" do
        own_assignment = create(:assignment, :to_group, group: group, text: text, assigned_by: teacher)
        other_assignment = create(:assignment, :to_user, user: learner, text: text, assigned_by: admin)
        get assignments_path
        expect(response.body).to include(text.title)
      end
    end

    context "学習者の場合" do
      before { sign_in learner }

      it "アクセスが拒否される" do
        get assignments_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /assignments" do
    context "教師の場合" do
      before { sign_in teacher }

      let(:valid_params) do
        {
          assignment: {
            text_id: text.id,
            group_id: group.id,
            deadline: 1.week.from_now
          }
        }
      end

      it "アサインメントが作成される" do
        expect {
          post assignments_path, params: valid_params
        }.to change(Assignment, :count).by(1)
      end

      it "assigned_byが設定される" do
        post assignments_path, params: valid_params
        expect(Assignment.last.assigned_by).to eq(teacher)
      end

      it "一覧にリダイレクトされる" do
        post assignments_path, params: valid_params
        expect(response).to redirect_to(assignments_path)
      end
    end
  end

  describe "DELETE /assignments/:id" do
    let!(:assignment) { create(:assignment, :to_group, group: group, text: text, assigned_by: teacher) }

    context "作成者の場合" do
      before { sign_in teacher }

      it "アサインメントが削除される" do
        expect {
          delete assignment_path(assignment)
        }.to change(Assignment, :count).by(-1)
      end
    end

    context "作成者でない場合" do
      let(:other_teacher) { create(:user, :teacher) }
      before { sign_in other_teacher }

      it "アクセスが拒否される" do
        delete assignment_path(assignment)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
