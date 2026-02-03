# frozen_string_literal: true

require "rails_helper"

RSpec.describe "WCAG 2.1 AA アクセシビリティ", type: :request do
  let(:learner) { create(:user, :learner) }

  describe "レイアウト" do
    before { sign_in learner }

    it "スキップナビゲーションリンクが存在する" do
      get root_path
      expect(response.body).to include('class="skip-to-main"')
      expect(response.body).to include('href="#main-content"')
    end

    it "mainランドマークにid属性が設定されている" do
      get root_path
      expect(response.body).to include('id="main-content"')
    end

    it "footerにrole=contentinfo属性が設定されている" do
      get root_path
      expect(response.body).to include('role="contentinfo"')
    end
  end

  describe "ナビゲーション" do
    before { sign_in learner }

    it "nav要素にaria-label属性が設定されている" do
      get root_path
      expect(response.body).to include('aria-label="メインナビゲーション"')
    end

    it "モバイルメニューにaria-label属性が設定されている" do
      get root_path
      expect(response.body).to include('aria-label="モバイルナビゲーション"')
    end
  end

  describe "Deviseビュー" do
    it "ログインフォームにaria-label属性が設定されている" do
      get new_user_session_path
      expect(response.body).to include('aria-label="ログインフォーム"')
    end

    it "ログインフォームの入力フィールドにaria-required属性が設定されている" do
      get new_user_session_path
      expect(response.body).to include('aria-required="true"')
    end

    it "新規登録フォームにaria-label属性が設定されている" do
      get new_user_registration_path
      expect(response.body).to include('aria-label="アカウント登録フォーム"')
    end

    it "パスワードリセットフォームにaria-label属性が設定されている" do
      get new_user_password_path
      expect(response.body).to include('aria-label="パスワードリセットフォーム"')
    end
  end
end
