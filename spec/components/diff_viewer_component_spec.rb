# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiffViewerComponent, type: :component do
  # diff配列のフォーマット: [{ type: :equal/:delete/:insert, text: "word" }, ...]

  describe "基本的なレンダリング" do
    it "差分表示エリアをレンダリングする" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-viewer")
    end

    it "空の差分の場合も正しくレンダリングする" do
      render_inline(described_class.new(diff: []))

      expect(page).to have_css(".diff-viewer")
    end
  end

  describe "一致部分の表示" do
    it "equalタイプは通常スタイルで表示される" do
      diff = [{ type: :equal, text: "正解" }]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-equal", text: "正解")
    end

    it "複数のequal要素が連続して表示される" do
      diff = [
        { type: :equal, text: "これは" },
        { type: :equal, text: "テスト" }
      ]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-equal", count: 2)
    end
  end

  describe "削除部分の表示（正解にあって提出にない）" do
    it "deleteタイプは赤色で取り消し線付きで表示される" do
      diff = [{ type: :delete, text: "欠落" }]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-delete", text: "欠落")
      expect(page).to have_css(".diff-delete.bg-red-100")
      expect(page).to have_css(".diff-delete.line-through")
    end
  end

  describe "挿入部分の表示（提出にあって正解にない）" do
    it "insertタイプは緑色で下線付きで表示される" do
      diff = [{ type: :insert, text: "余分" }]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-insert", text: "余分")
      expect(page).to have_css(".diff-insert.bg-green-100")
      expect(page).to have_css(".diff-insert.underline")
    end
  end

  describe "複合的な差分の表示" do
    it "正解・削除・挿入が混在する差分を正しく表示する" do
      diff = [
        { type: :equal, text: "これは" },
        { type: :delete, text: "正解" },
        { type: :insert, text: "間違い" },
        { type: :equal, text: "です" }
      ]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-equal", count: 2)
      expect(page).to have_css(".diff-delete", count: 1)
      expect(page).to have_css(".diff-insert", count: 1)
    end
  end

  describe "スタイルバリアント" do
    it "inlineモードがデフォルト" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css(".diff-viewer.diff-inline")
    end

    it "side_by_sideモードを指定できる" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff, mode: :side_by_side))

      expect(page).to have_css(".diff-viewer.diff-side-by-side")
    end
  end

  describe "オプション設定" do
    it "show_legendがtrueの場合、凡例を表示する" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff, show_legend: true))

      expect(page).to have_css(".diff-legend")
      expect(page).to have_text("正解")
      expect(page).to have_text("欠落")
      expect(page).to have_text("余分")
    end

    it "show_legendがfalseの場合、凡例を表示しない" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff, show_legend: false))

      expect(page).not_to have_css(".diff-legend")
    end
  end

  describe "完全一致の場合" do
    it "すべてequalの場合、成功メッセージを表示できる" do
      diff = [
        { type: :equal, text: "完全" },
        { type: :equal, text: "一致" }
      ]
      render_inline(described_class.new(diff: diff, show_success_message: true))

      expect(page).to have_css(".diff-success")
      expect(page).to have_text("完璧")
    end

    it "show_success_messageがfalseの場合、成功メッセージを表示しない" do
      diff = [
        { type: :equal, text: "完全" },
        { type: :equal, text: "一致" }
      ]
      render_inline(described_class.new(diff: diff, show_success_message: false))

      expect(page).not_to have_css(".diff-success")
    end
  end

  describe "スコア表示" do
    it "show_scoreがtrueの場合、スコアを計算して表示する" do
      diff = [
        { type: :equal, text: "正解" },
        { type: :equal, text: "です" },
        { type: :delete, text: "欠落" },
        { type: :insert, text: "余分" }
      ]
      render_inline(described_class.new(diff: diff, show_score: true))

      expect(page).to have_css(".diff-score")
    end

    it "show_scoreがfalseの場合、スコアを表示しない" do
      diff = [{ type: :equal, text: "テスト" }]
      render_inline(described_class.new(diff: diff, show_score: false))

      expect(page).not_to have_css(".diff-score")
    end
  end

  describe "アクセシビリティ" do
    it "各差分タイプにaria-labelが設定される" do
      diff = [
        { type: :equal, text: "正解" },
        { type: :delete, text: "欠落" },
        { type: :insert, text: "余分" }
      ]
      render_inline(described_class.new(diff: diff))

      expect(page).to have_css("[aria-label='一致']")
      expect(page).to have_css("[aria-label='欠落している単語']")
      expect(page).to have_css("[aria-label='余分な単語']")
    end
  end

  describe "単語間のスペース" do
    it "各単語が個別のspan要素で表示される" do
      diff = [
        { type: :equal, text: "これは" },
        { type: :equal, text: "テスト" }
      ]
      render_inline(described_class.new(diff: diff))

      # 各単語が別々のspan要素として表示される
      expect(page).to have_css("span", text: "これは")
      expect(page).to have_css("span", text: "テスト")
    end
  end
end
