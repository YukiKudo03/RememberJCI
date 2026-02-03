# frozen_string_literal: true

require 'rails_helper'

# spec/system/authentication_spec.rb
RSpec.describe "認証", type: :system do
  describe "ユーザー登録" do
    context "有効な情報を入力した場合" do
      it "ユーザーが作成される" do
        visit new_user_registration_path
        fill_in "メールアドレス", with: "new@example.com"
        fill_in "名前", with: "新規ユーザー"
        fill_in "パスワード", with: "password123"
        fill_in "パスワード（確認）", with: "password123"
        click_button "登録"

        expect(page).to have_content("本人確認用のメールを送信しました")
      end
    end

    context "無効な情報を入力した場合" do
      it "エラーメッセージが表示される" do
        visit new_user_registration_path
        fill_in "メールアドレス", with: ""
        click_button "登録"

        expect(page).to have_content("メールアドレスを入力してください")
      end
    end
  end

  describe "ログイン" do
    let!(:user) { create(:user, email: "test@example.com", password: "password123") }

    context "正しい認証情報の場合" do
      it "ダッシュボードにリダイレクトされる" do
        visit new_user_session_path
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "password123"
        click_button "ログイン"

        expect(page).to have_current_path(root_path)
        expect(page).to have_content("ログインしました")
      end
    end

    context "誤った認証情報の場合" do
      it "エラーメッセージが表示される" do
        visit new_user_session_path
        fill_in "メールアドレス", with: "test@example.com"
        fill_in "パスワード", with: "wrongpassword"
        click_button "ログイン"

        expect(page).to have_content("メールアドレスまたはパスワードが違います")
      end
    end
  end

  describe "ログアウト" do
    let!(:user) { create(:user) }

    it "ログアウトできる" do
      sign_in user
      visit root_path
      # Desktop navigation has logout button, find first visible one
      first("button", text: "ログアウト", visible: true).click

      expect(page).to have_content("ログアウトしました")
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
