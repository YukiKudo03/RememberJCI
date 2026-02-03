# frozen_string_literal: true

require "rails_helper"

RSpec.describe Learning::TextDisplayComponent, type: :component do
  let(:text_content) { "これは テスト 文章です" }
  let(:original_text) { "これは テスト 文章です" }

  describe "レベル0（全文表示）" do
    it "全ての単語が表示される" do
      render_inline(described_class.new(text_content: text_content, original_text: original_text, level: 0))

      expect(page).to have_text("これは")
      expect(page).to have_text("テスト")
      expect(page).to have_text("文章です")
    end

    it "空欄がない" do
      render_inline(described_class.new(text_content: text_content, original_text: original_text, level: 0))

      expect(page).not_to have_css(".blank")
    end
  end

  describe "空欄を含むコンテンツの表示" do
    let(:content_with_blanks) { "これは ____ 文章です" }

    it "空欄部分が特別なスタイルで表示される" do
      render_inline(described_class.new(text_content: content_with_blanks, original_text: original_text, level: 2))

      expect(page).to have_css(".blank")
    end

    it "空欄以外の単語は通常表示される" do
      render_inline(described_class.new(text_content: content_with_blanks, original_text: original_text, level: 2))

      expect(page).to have_text("これは")
      expect(page).to have_text("文章です")
    end
  end

  describe "レベル5（全て空欄）" do
    let(:all_blanks_content) { "____ ____ ____" }

    it "全ての単語が空欄として表示される" do
      render_inline(described_class.new(text_content: all_blanks_content, original_text: original_text, level: 5))

      blanks = page.all(".blank")
      expect(blanks.count).to eq(3)
    end

    it "完了メッセージが表示される" do
      render_inline(described_class.new(text_content: all_blanks_content, original_text: original_text, level: 5))

      expect(page).to have_css("[data-level='5']")
    end
  end

  describe "答えの表示機能" do
    let(:content_with_blanks) { "これは ____ 文章です" }

    context "show_answersがtrueの場合" do
      it "元のテキストが表示される" do
        render_inline(described_class.new(
          text_content: content_with_blanks,
          original_text: original_text,
          level: 2,
          show_answers: true
        ))

        expect(page).to have_text("テスト")
      end
    end

    context "show_answersがfalseの場合" do
      it "空欄のままで表示される" do
        render_inline(described_class.new(
          text_content: content_with_blanks,
          original_text: original_text,
          level: 2,
          show_answers: false
        ))

        expect(page).to have_css(".blank")
      end
    end
  end

  describe "インタラクティブモード" do
    let(:content_with_blanks) { "これは ____ 文章です" }

    it "interactiveがtrueの場合、空欄がクリック可能になる" do
      render_inline(described_class.new(
        text_content: content_with_blanks,
        original_text: original_text,
        level: 2,
        interactive: true
      ))

      expect(page).to have_css(".blank[data-action]")
    end

    it "interactiveがfalseの場合、空欄はクリック不可" do
      render_inline(described_class.new(
        text_content: content_with_blanks,
        original_text: original_text,
        level: 2,
        interactive: false
      ))

      expect(page).not_to have_css(".blank[data-action]")
    end
  end

  describe "data属性" do
    it "レベル情報がdata属性で渡される" do
      render_inline(described_class.new(text_content: text_content, original_text: original_text, level: 3))

      expect(page).to have_css("[data-level='3']")
    end

    it "Stimulusコントローラーへの接続が設定される" do
      render_inline(described_class.new(
        text_content: text_content,
        original_text: original_text,
        level: 0,
        interactive: true
      ))

      expect(page).to have_css("[data-controller='text-display']")
    end
  end

  describe "スタイリング" do
    it "proseクラスが適用される" do
      render_inline(described_class.new(text_content: text_content, original_text: original_text, level: 0))

      expect(page).to have_css(".prose")
    end

    it "空欄には視覚的な区別がある" do
      content_with_blanks = "これは ____ です"
      render_inline(described_class.new(text_content: content_with_blanks, original_text: original_text, level: 2))

      expect(page).to have_css(".blank.bg-gray-100")
    end
  end
end
