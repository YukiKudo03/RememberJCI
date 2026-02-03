# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalComponent, type: :component do
  describe "サイズ" do
    it "smサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :sm)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css(".max-w-sm")
    end

    it "mdサイズがデフォルト" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css(".max-w-md")
    end

    it "lgサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :lg)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css(".max-w-lg")
    end

    it "xlサイズのスタイルが適用される" do
      render_inline(described_class.new(size: :xl)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css(".max-w-xl")
    end
  end

  describe "タイトル" do
    it "タイトルが指定された場合、表示される" do
      render_inline(described_class.new(title: "モーダルタイトル")) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[data-modal-target='title']", text: "モーダルタイトル")
    end

    it "タイトルがない場合、ヘッダーセクションが非表示" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).not_to have_css("[data-modal-target='title']")
    end
  end

  describe "閉じるボタン" do
    it "閉じるボタンが表示される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("button[data-action='modal#close']")
    end

    it "closeable: falseの場合、閉じるボタンが非表示" do
      render_inline(described_class.new(closeable: false)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).not_to have_css("button[data-action='modal#close']")
    end
  end

  describe "Stimulus controller" do
    it "data-controller属性が設定される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[data-controller='modal']")
    end

    it "data-action属性が設定される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[data-action*='keydown.esc->modal#closeOnEsc']")
    end

    it "backdrop clickでcloseが設定される" do
      render_inline(described_class.new(close_on_backdrop: true)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[data-action*='click->modal#closeOnBackdrop']")
    end

    it "close_on_backdrop: falseの場合、backdrop clickが無効" do
      render_inline(described_class.new(close_on_backdrop: false)) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).not_to have_css("[data-action*='click->modal#closeOnBackdrop']")
    end
  end

  describe "スロット" do
    it "bodyスロットのコンテンツが表示される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "ボディコンテンツ" }
      end

      expect(page).to have_css("[data-modal-target='body']", text: "ボディコンテンツ")
    end

    it "footerスロットのコンテンツが表示される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "ボディ" }
        modal.with_footer { "フッターコンテンツ" }
      end

      expect(page).to have_css("[data-modal-target='footer']", text: "フッターコンテンツ")
    end

    it "headerスロットのコンテンツが表示される" do
      render_inline(described_class.new) do |modal|
        modal.with_header { "カスタムヘッダー" }
        modal.with_body { "ボディ" }
      end

      expect(page).to have_css("[data-modal-target='header']", text: "カスタムヘッダー")
    end

    it "footerスロットがない場合、フッターセクションが非表示" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "ボディのみ" }
      end

      expect(page).not_to have_css("[data-modal-target='footer']")
    end
  end

  describe "HTML属性" do
    it "追加のHTML属性が適用される" do
      render_inline(described_class.new(id: "my-modal", data: { test: "value" })) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("#my-modal")
      expect(page).to have_css("[data-test='value']")
    end

    it "カスタムクラスが追加される" do
      render_inline(described_class.new(class: "custom-class")) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css(".custom-class")
    end
  end

  describe "アクセシビリティ" do
    it "role属性が設定される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[role='dialog']")
    end

    it "aria-modal属性が設定される" do
      render_inline(described_class.new) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[aria-modal='true']")
    end

    it "タイトルがある場合、aria-labelledby属性が設定される" do
      render_inline(described_class.new(title: "テストタイトル")) do |modal|
        modal.with_body { "コンテンツ" }
      end

      expect(page).to have_css("[aria-labelledby]")
    end
  end
end
