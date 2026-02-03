# frozen_string_literal: true

require "rails_helper"

RSpec.describe TimerComponent, type: :component do
  describe "基本的なレンダリング" do
    it "タイマー表示エリアをレンダリングする" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css("[data-controller='timer']")
    end

    it "制限時間を表示する" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_text("30:00")
    end

    it "Stimulusコントローラーのdata属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css("[data-timer-duration-value='1800']") # 30 * 60 = 1800秒
    end
  end

  describe "異なる制限時間の表示" do
    it "1分の場合は01:00と表示される" do
      render_inline(described_class.new(duration_minutes: 1))

      expect(page).to have_text("01:00")
    end

    it "60分の場合は60:00と表示される" do
      render_inline(described_class.new(duration_minutes: 60))

      expect(page).to have_text("60:00")
    end

    it "90分の場合は90:00と表示される" do
      render_inline(described_class.new(duration_minutes: 90))

      expect(page).to have_text("90:00")
    end
  end

  describe "オプション設定" do
    it "auto_startがtrueの場合、data属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30, auto_start: true))

      expect(page).to have_css("[data-timer-auto-start-value='true']")
    end

    it "auto_startがfalseの場合、data属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30, auto_start: false))

      expect(page).to have_css("[data-timer-auto-start-value='false']")
    end

    it "show_warningがtrueの場合、警告用のdata属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30, warning_threshold: 300))

      expect(page).to have_css("[data-timer-warning-threshold-value='300']")
    end

    it "on_expireコールバックを設定できる" do
      render_inline(described_class.new(duration_minutes: 30, on_expire: "handleExpire"))

      expect(page).to have_css("[data-timer-on-expire-value='handleExpire']")
    end
  end

  describe "スタイルバリアント" do
    it "デフォルトはnormalサイズ" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css(".timer-normal")
    end

    it "largeサイズを指定できる" do
      render_inline(described_class.new(duration_minutes: 30, size: :large))

      expect(page).to have_css(".timer-large")
    end

    it "compactサイズを指定できる" do
      render_inline(described_class.new(duration_minutes: 30, size: :compact))

      expect(page).to have_css(".timer-compact")
    end
  end

  describe "フォーマット" do
    it "残り時間のターゲット要素が存在する" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css("[data-timer-target='display']")
    end

    it "アイコンが表示される" do
      render_inline(described_class.new(duration_minutes: 30, show_icon: true))

      expect(page).to have_css("svg")
    end

    it "show_iconがfalseの場合、アイコンが表示されない" do
      render_inline(described_class.new(duration_minutes: 30, show_icon: false))

      expect(page).not_to have_css("svg")
    end
  end

  describe "アクセシビリティ" do
    it "aria-liveが設定される" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css("[aria-live='polite']")
    end

    it "role=timerが設定される" do
      render_inline(described_class.new(duration_minutes: 30))

      expect(page).to have_css("[role='timer']")
    end
  end

  describe "警告状態" do
    it "警告閾値のdata属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30, warning_threshold: 60))

      expect(page).to have_css("[data-timer-warning-threshold-value='60']")
    end

    it "危険閾値のdata属性が設定される" do
      render_inline(described_class.new(duration_minutes: 30, danger_threshold: 30))

      expect(page).to have_css("[data-timer-danger-threshold-value='30']")
    end
  end
end
