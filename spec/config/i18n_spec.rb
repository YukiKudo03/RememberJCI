# frozen_string_literal: true

require "rails_helper"

RSpec.describe "i18n設定", type: :config do
  describe "利用可能なロケール" do
    it "日本語が利用可能" do
      expect(I18n.available_locales).to include(:ja)
    end

    it "英語が利用可能" do
      expect(I18n.available_locales).to include(:en)
    end
  end

  describe "デフォルトロケール" do
    it "日本語がデフォルト" do
      expect(I18n.default_locale).to eq(:ja)
    end
  end

  describe "ロケール切り替え" do
    after do
      I18n.locale = I18n.default_locale
    end

    it "英語に切り替えできる" do
      I18n.locale = :en
      expect(I18n.locale).to eq(:en)
    end

    it "日本語に切り替えできる" do
      I18n.locale = :ja
      expect(I18n.locale).to eq(:ja)
    end
  end

  describe "共通翻訳キー" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "アプリ名が翻訳されている" do
        expect(I18n.t("app_name")).to eq("RememberIt")
      end

      it "ナビゲーションが翻訳されている" do
        expect(I18n.t("nav.home")).to eq("ホーム")
        expect(I18n.t("nav.login")).to eq("ログイン")
        expect(I18n.t("nav.logout")).to eq("ログアウト")
        expect(I18n.t("nav.signup")).to eq("新規登録")
      end

      it "共通アクションが翻訳されている" do
        expect(I18n.t("actions.save")).to eq("保存")
        expect(I18n.t("actions.cancel")).to eq("キャンセル")
        expect(I18n.t("actions.edit")).to eq("編集")
        expect(I18n.t("actions.delete")).to eq("削除")
        expect(I18n.t("actions.back")).to eq("戻る")
      end

      it "フラッシュメッセージが翻訳されている" do
        expect(I18n.t("flash.created")).to eq("作成しました")
        expect(I18n.t("flash.updated")).to eq("更新しました")
        expect(I18n.t("flash.deleted")).to eq("削除しました")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "アプリ名が翻訳されている" do
        expect(I18n.t("app_name")).to eq("RememberIt")
      end

      it "ナビゲーションが翻訳されている" do
        expect(I18n.t("nav.home")).to eq("Home")
        expect(I18n.t("nav.login")).to eq("Login")
        expect(I18n.t("nav.logout")).to eq("Logout")
        expect(I18n.t("nav.signup")).to eq("Sign Up")
      end

      it "共通アクションが翻訳されている" do
        expect(I18n.t("actions.save")).to eq("Save")
        expect(I18n.t("actions.cancel")).to eq("Cancel")
        expect(I18n.t("actions.edit")).to eq("Edit")
        expect(I18n.t("actions.delete")).to eq("Delete")
        expect(I18n.t("actions.back")).to eq("Back")
      end

      it "フラッシュメッセージが翻訳されている" do
        expect(I18n.t("flash.created")).to eq("Successfully created")
        expect(I18n.t("flash.updated")).to eq("Successfully updated")
        expect(I18n.t("flash.deleted")).to eq("Successfully deleted")
      end
    end
  end

  describe "フォールバック" do
    it "フォールバック設定が存在する" do
      # テスト環境でフォールバックが設定されていることを確認
      # config/environments/test.rb で config.i18n.fallbacks = [:en] を設定
      expect(I18n.fallbacks[:ja]).to include(:en)
    end
  end
end
