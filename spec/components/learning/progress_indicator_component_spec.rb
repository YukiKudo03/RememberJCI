# frozen_string_literal: true

require "rails_helper"

RSpec.describe Learning::ProgressIndicatorComponent, type: :component do
  describe "基本的なレンダリング" do
    it "進捗バーをレンダリングする" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_css(".progress-indicator")
    end

    it "プログレスバーが表示される" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_css("[role='progressbar']")
    end
  end

  describe "進捗率の計算" do
    it "50/100の場合、50%と表示される" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_text("50%")
    end

    it "0/100の場合、0%と表示される" do
      render_inline(described_class.new(current: 0, total: 100))

      expect(page).to have_text("0%")
    end

    it "100/100の場合、100%と表示される" do
      render_inline(described_class.new(current: 100, total: 100))

      expect(page).to have_text("100%")
    end

    it "33/100の場合、33%と表示される" do
      render_inline(described_class.new(current: 33, total: 100))

      expect(page).to have_text("33%")
    end

    it "totalが0の場合、0%と表示される" do
      render_inline(described_class.new(current: 0, total: 0))

      expect(page).to have_text("0%")
    end
  end

  describe "バーの幅" do
    it "進捗率に応じたstyle属性が設定される" do
      render_inline(described_class.new(current: 75, total: 100))

      expect(page).to have_css("[style*='width: 75%']")
    end

    it "0%の場合、幅が0%" do
      render_inline(described_class.new(current: 0, total: 100))

      expect(page).to have_css("[style*='width: 0%']")
    end
  end

  describe "アクセシビリティ" do
    it "aria-valuenowが設定される" do
      render_inline(described_class.new(current: 60, total: 100))

      expect(page).to have_css("[aria-valuenow='60']")
    end

    it "aria-valueminが設定される" do
      render_inline(described_class.new(current: 60, total: 100))

      expect(page).to have_css("[aria-valuemin='0']")
    end

    it "aria-valuemaxが設定される" do
      render_inline(described_class.new(current: 60, total: 100))

      expect(page).to have_css("[aria-valuemax='100']")
    end
  end

  describe "ラベル表示" do
    it "デフォルトでラベルが表示される" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_text("50%")
    end

    it "カスタムラベルを指定できる" do
      render_inline(described_class.new(current: 5, total: 10, label: "5 / 10 完了"))

      expect(page).to have_text("5 / 10 完了")
    end

    it "show_labelがfalseの場合、ラベルが非表示" do
      render_inline(described_class.new(current: 50, total: 100, show_label: false))

      expect(page).not_to have_css(".progress-label")
    end
  end

  describe "スタイルバリアント" do
    it "デフォルトはnormalサイズ" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_css(".progress-normal")
    end

    it "thinサイズを指定できる" do
      render_inline(described_class.new(current: 50, total: 100, size: :thin))

      expect(page).to have_css(".progress-thin")
    end

    it "thickサイズを指定できる" do
      render_inline(described_class.new(current: 50, total: 100, size: :thick))

      expect(page).to have_css(".progress-thick")
    end
  end

  describe "色のバリアント" do
    it "デフォルトはindigo色" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_css(".bg-indigo-600")
    end

    it "green色を指定できる" do
      render_inline(described_class.new(current: 50, total: 100, color: :green))

      expect(page).to have_css(".bg-green-600")
    end

    it "red色を指定できる" do
      render_inline(described_class.new(current: 50, total: 100, color: :red))

      expect(page).to have_css(".bg-red-600")
    end
  end

  describe "完了状態" do
    it "100%の場合、完了スタイルが適用される" do
      render_inline(described_class.new(current: 100, total: 100))

      expect(page).to have_css(".progress-complete")
    end

    it "100%未満の場合、完了スタイルが適用されない" do
      render_inline(described_class.new(current: 99, total: 100))

      expect(page).not_to have_css(".progress-complete")
    end
  end

  describe "アニメーション" do
    it "デフォルトでアニメーションが有効" do
      render_inline(described_class.new(current: 50, total: 100))

      expect(page).to have_css(".transition-all")
    end

    it "animatedがfalseの場合、アニメーションが無効" do
      render_inline(described_class.new(current: 50, total: 100, animated: false))

      expect(page).not_to have_css(".transition-all")
    end
  end
end
