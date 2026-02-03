# spec/requests/admin/users_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }

  describe "GET /admin/users" do
    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "全ユーザーが表示される" do
        teacher
        learner
        get admin_users_path
        expect(response.body).to include(teacher.name)
        expect(response.body).to include(learner.name)
      end
    end

    context "管理者でない場合" do
      before { sign_in teacher }

      it "アクセスが拒否される" do
        get admin_users_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /admin/users" do
    before { sign_in admin }

    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          user: {
            email: "new@example.com",
            name: "新規ユーザー",
            password: "password123",
            role: "learner"
          }
        }
      end

      it "ユーザーが作成される" do
        expect {
          post admin_users_path, params: valid_params
        }.to change(User, :count).by(1)
      end

      it "一覧にリダイレクトされる" do
        post admin_users_path, params: valid_params
        expect(response).to redirect_to(admin_users_path)
      end

      it "招待メールが送信される" do
        expect {
          post admin_users_path, params: valid_params
        }.to have_enqueued_mail(UserMailer, :welcome)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        { user: { email: "", name: "" } }
      end

      it "ユーザーが作成されない" do
        expect {
          post admin_users_path, params: invalid_params
        }.not_to change(User, :count)
      end
    end
  end

  describe "GET /admin/users/import" do
    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get import_admin_users_path
        expect(response).to have_http_status(:success)
      end

      it "インポートフォームが表示される" do
        get import_admin_users_path
        expect(response.body).to include("CSVインポート")
        expect(response.body).to include("CSVファイル")
      end
    end

    context "管理者でない場合" do
      before { sign_in teacher }

      it "アクセスが拒否される" do
        get import_admin_users_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /admin/users/import" do
    before { sign_in admin }

    context "有効なCSVファイルの場合" do
      let(:csv_content) { "email,name,role,password\nimport1@example.com,インポートユーザー1,learner,password123" }
      let(:csv_file) { fixture_file_upload_from_content(csv_content, "users.csv", "text/csv") }

      it "ユーザーがインポートされる" do
        expect {
          post import_admin_users_path, params: { file: csv_file }
        }.to change(User, :count).by(1)
      end

      it "一覧にリダイレクトされる" do
        post import_admin_users_path, params: { file: csv_file }
        expect(response).to redirect_to(admin_users_path)
      end

      it "成功メッセージが表示される" do
        post import_admin_users_path, params: { file: csv_file }
        follow_redirect!
        expect(response.body).to include("インポートしました")
      end
    end

    context "ファイルが選択されていない場合" do
      it "エラーが表示される" do
        post import_admin_users_path
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("ファイルを選択してください")
      end
    end

    context "無効なデータを含むCSVの場合" do
      let(:csv_content) { "email,name,role,password\n,名前のみ,learner,password123" }
      let(:csv_file) { fixture_file_upload_from_content(csv_content, "users.csv", "text/csv") }

      it "エラーが表示される" do
        post import_admin_users_path, params: { file: csv_file }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("インポートエラー")
      end
    end

    context "管理者でない場合" do
      before { sign_in teacher }

      it "アクセスが拒否される" do
        post import_admin_users_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
