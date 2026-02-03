# frozen_string_literal: true

require "rails_helper"

RSpec.describe SidebarComponent, type: :component do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:admin) { create(:user, :admin) }

  describe "基本的なレンダリング" do
    it "サイドバー要素をレンダリングする" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_css("aside")
    end

    it "ナビゲーションリストが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_css("nav")
    end
  end

  describe "学習者のナビゲーション" do
    it "ダッシュボードが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_link("ダッシュボード")
    end

    it "学習が表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_link("学習")
    end

    it "進捗が表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_link("進捗")
    end

    it "テストが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_link("テスト")
    end

    it "管理者メニューが表示されない" do
      render_inline(described_class.new(current_user: learner))

      expect(page).not_to have_link("ユーザー管理")
    end
  end

  describe "教師のナビゲーション" do
    it "グループが表示される" do
      render_inline(described_class.new(current_user: teacher))

      expect(page).to have_link("グループ")
    end

    it "課題が表示される" do
      render_inline(described_class.new(current_user: teacher))

      expect(page).to have_link("課題")
    end

    it "分析が表示される" do
      render_inline(described_class.new(current_user: teacher))

      expect(page).to have_link("分析")
    end
  end

  describe "管理者のナビゲーション" do
    it "ユーザー管理が表示される" do
      render_inline(described_class.new(current_user: admin))

      expect(page).to have_link("ユーザー管理")
    end

    it "テキスト管理が表示される" do
      render_inline(described_class.new(current_user: admin))

      expect(page).to have_link("テキスト管理")
    end
  end

  describe "アクティブ状態" do
    it "現在のパスに一致するアイテムがアクティブになる" do
      render_inline(described_class.new(current_user: learner, current_path: "/learning/texts"))

      expect(page).to have_css(".sidebar-item-active")
    end

    it "一致しないアイテムはアクティブにならない" do
      render_inline(described_class.new(current_user: learner, current_path: "/other"))

      expect(page).not_to have_css(".sidebar-item-active")
    end
  end

  describe "アイコン表示" do
    it "各メニューにアイコンが表示される" do
      render_inline(described_class.new(current_user: learner))

      expect(page).to have_css("svg", minimum: 1)
    end
  end

  describe "折りたたみ機能" do
    it "Stimulusコントローラーが設定される" do
      render_inline(described_class.new(current_user: learner, collapsible: true))

      expect(page).to have_css("[data-controller='sidebar']")
    end

    it "折りたたみボタンが表示される" do
      render_inline(described_class.new(current_user: learner, collapsible: true))

      expect(page).to have_css("[data-action*='sidebar#toggle']")
    end

    it "collapsibleがfalseの場合、折りたたみボタンが非表示" do
      render_inline(described_class.new(current_user: learner, collapsible: false))

      expect(page).not_to have_css("[data-action*='sidebar#toggle']")
    end
  end

  describe "セクション分割" do
    it "メインナビゲーションセクションがある" do
      render_inline(described_class.new(current_user: admin))

      expect(page).to have_css("[data-section='main']")
    end

    it "管理者には管理セクションがある" do
      render_inline(described_class.new(current_user: admin))

      expect(page).to have_css("[data-section='admin']")
    end

    it "学習者には管理セクションがない" do
      render_inline(described_class.new(current_user: learner))

      expect(page).not_to have_css("[data-section='admin']")
    end
  end
end
