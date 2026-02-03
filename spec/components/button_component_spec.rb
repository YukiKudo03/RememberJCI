# frozen_string_literal: true

require "rails_helper"

RSpec.describe ButtonComponent, type: :component do
  describe "バリアント" do
    it "primaryバリアントのスタイルが適用される" do
      render_inline(described_class.new(variant: :primary)) { "ボタン" }

      expect(page).to have_css("button.bg-blue-600")
      expect(page).to have_css("button.text-white")
    end

    it "secondaryバリアントのスタイルが適用される" do
      render_inline(described_class.new(variant: :secondary)) { "ボタン" }

      expect(page).to have_css("button.bg-gray-200")
      expect(page).to have_css("button.text-gray-900")
    end

    it "dangerバリアントのスタイルが適用される" do
      render_inline(described_class.new(variant: :danger)) { "ボタン" }

      expect(page).to have_css("button.bg-red-600")
      expect(page).to have_css("button.text-white")
    end

    it "ghostバリアントのスタイルが適用される" do
      render_inline(described_class.new(variant: :ghost)) { "ボタン" }

      expect(page).to have_css("button.bg-transparent")
      expect(page).to have_css("button.text-gray-700")
    end
  end

  describe "サイズ" do
    it "smサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :sm)) { "ボタン" }

      expect(page).to have_css("button.px-3")
      expect(page).to have_css("button.py-1\\.5")
      expect(page).to have_css("button.text-sm")
    end

    it "mdサイズがデフォルト" do
      render_inline(described_class.new) { "ボタン" }

      expect(page).to have_css("button.px-4")
      expect(page).to have_css("button.py-2")
      expect(page).to have_css("button.text-base")
    end

    it "lgサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :lg)) { "ボタン" }

      expect(page).to have_css("button.px-6")
      expect(page).to have_css("button.py-3")
      expect(page).to have_css("button.text-lg")
    end
  end

  describe "オプション" do
    it "disabledの場合、disabled属性が付与される" do
      render_inline(described_class.new(disabled: true)) { "ボタン" }

      expect(page).to have_css("button[disabled]")
      expect(page).to have_css("button.opacity-50")
      expect(page).to have_css("button.cursor-not-allowed")
    end

    it "full_widthの場合、w-fullクラスが適用される" do
      render_inline(described_class.new(full_width: true)) { "ボタン" }

      expect(page).to have_css("button.w-full")
    end

    it "hrefが指定された場合、aタグとしてレンダリングされる" do
      render_inline(described_class.new(href: "/path/to/page")) { "リンクボタン" }

      expect(page).to have_css('a[href="/path/to/page"]')
      expect(page).not_to have_css("button")
      expect(page).to have_text("リンクボタン")
    end

    it "追加のHTML属性が適用される" do
      render_inline(described_class.new(id: "my-button", data: { action: "click->test#handle" })) { "ボタン" }

      expect(page).to have_css("button#my-button")
      expect(page).to have_css('button[data-action="click->test#handle"]')
    end
  end

  describe "コンテンツ" do
    it "ブロックで渡されたコンテンツが表示される" do
      render_inline(described_class.new) { "送信する" }

      expect(page).to have_button("送信する")
    end

    it "HTMLコンテンツも正しく表示される" do
      render_inline(described_class.new) do
        "<span>アイコン</span> テキスト".html_safe
      end

      expect(page).to have_css("button span", text: "アイコン")
      expect(page).to have_text("テキスト")
    end
  end

  describe "バリアントとサイズの組み合わせ" do
    it "異なるバリアントとサイズを組み合わせてレンダリングできる" do
      render_inline(described_class.new(variant: :danger, size: :lg)) { "削除" }

      expect(page).to have_css("button.bg-red-600")
      expect(page).to have_css("button.px-6")
    end
  end

  describe "リンクボタンのスタイル" do
    it "リンクボタンにもバリアントのスタイルが適用される" do
      render_inline(described_class.new(variant: :secondary, href: "/test")) { "リンク" }

      expect(page).to have_css("a.bg-gray-200")
      expect(page).to have_css('a[href="/test"]')
    end

    it "リンクボタンにもサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :sm, href: "/test")) { "リンク" }

      expect(page).to have_css("a.px-3")
      expect(page).to have_css("a.text-sm")
    end
  end
end
