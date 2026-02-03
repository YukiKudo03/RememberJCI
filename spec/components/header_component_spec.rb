# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeaderComponent, type: :component do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:admin) { create(:user, :admin) }

  describe "基本的なレンダリング" do
    it "ヘッダー要素をレンダリングする" do
      render_inline(described_class.new)

      expect(page).to have_css("header")
    end

    it "アプリ名が表示される" do
      render_inline(described_class.new)

      expect(page).to have_text("RememberIt")
    end

    it "ロゴにホームへのリンクがある" do
      render_inline(described_class.new)

      expect(page).to have_link("RememberIt", href: "/")
    end
  end

  describe "未ログイン時" do
    it "ログインリンクが表示される" do
      render_inline(described_class.new)

      expect(page).to have_link("ログイン")
    end

    it "新規登録リンクが表示される" do
      render_inline(described_class.new)

      expect(page).to have_link("新規登録")
    end

    it "ユーザーメニューが表示されない" do
      render_inline(described_class.new)

      expect(page).not_to have_text("ログアウト")
    end
  end

  describe "ログイン時" do
    it "ユーザー名が表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_text(learner.name)
    end

    it "ログアウトボタンが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_text("ログアウト")
    end

    it "ログイン/新規登録リンクが表示されない" do
      render_inline(described_class.new(current_user: learner))

      expect(page).not_to have_link("ログイン")
      expect(page).not_to have_link("新規登録")
    end
  end

  describe "ロールバッジ" do
    it "学習者バッジが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_text("学習者")
    end

    it "教師バッジが表示される" do
      render_inline(described_class.new(current_user: teacher))

      expect(page).to have_text("教師")
    end

    it "管理者バッジが表示される" do
      render_inline(described_class.new(current_user: admin))

      expect(page).to have_text("管理者")
    end
  end

  describe "モバイルメニュー" do
    it "モバイルメニューボタンが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_css("[data-action*='toggle']")
    end

    it "Stimulusコントローラーが設定される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_css("[data-controller='navigation']")
    end
  end

  describe "スタイルバリアント" do
    it "デフォルトはsticky設定" do
      render_inline(described_class.new)

      expect(page).to have_css("header.sticky")
    end

    it "stickyを無効にできる" do
      render_inline(described_class.new(sticky: false))

      expect(page).not_to have_css("header.sticky")
    end
  end

  describe "カスタマイズ" do
    it "追加のCSSクラスを指定できる" do
      render_inline(described_class.new(class_name: "custom-class"))

      expect(page).to have_css("header.custom-class")
    end
  end
end
