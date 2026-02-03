# spec/requests/admin/texts_spec.rb
require 'rails_helper'

RSpec.describe "Admin::Texts", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:teacher) { create(:user, :teacher) }
  let(:text) { create(:text, created_by: admin) }

  describe "GET /admin/texts" do
    context "管理者の場合" do
      before { sign_in admin }

      it "成功する" do
        get admin_texts_path
        expect(response).to have_http_status(:success)
      end

      it "全テキストが表示される" do
        text
        get admin_texts_path
        expect(response.body).to include(text.title)
      end
    end

    context "管理者でない場合" do
      before { sign_in teacher }

      it "アクセスが拒否される" do
        get admin_texts_path
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "POST /admin/texts" do
    before { sign_in admin }

    context "有効なパラメータの場合" do
      let(:valid_params) do
        {
          text: {
            title: "新規テキスト",
            content: "これは暗記用のテキストです",
            category: "一般",
            difficulty: "medium"
          }
        }
      end

      it "テキストが作成される" do
        expect {
          post admin_texts_path, params: valid_params
        }.to change(Text, :count).by(1)
      end

      it "一覧にリダイレクトされる" do
        post admin_texts_path, params: valid_params
        expect(response).to redirect_to(admin_texts_path)
      end
    end

    context "無効なパラメータの場合" do
      let(:invalid_params) do
        { text: { title: "", content: "" } }
      end

      it "テキストが作成されない" do
        expect {
          post admin_texts_path, params: invalid_params
        }.not_to change(Text, :count)
      end
    end
  end

  describe "PATCH /admin/texts/:id" do
    before { sign_in admin }

    it "テキストが更新される" do
      patch admin_text_path(text), params: { text: { title: "更新タイトル" } }
      expect(text.reload.title).to eq("更新タイトル")
    end
  end

  describe "DELETE /admin/texts/:id" do
    before { sign_in admin }

    it "テキストが削除される" do
      text # create before the expect block
      expect {
        delete admin_text_path(text)
      }.to change(Text, :count).by(-1)
    end
  end
end
