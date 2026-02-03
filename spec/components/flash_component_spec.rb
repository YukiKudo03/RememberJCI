# frozen_string_literal: true

require "rails_helper"

RSpec.describe FlashComponent, type: :component do
  describe "基本的なレンダリング" do
    it "フラッシュメッセージをレンダリングする" do
      render_inline(described_class.new(type: :notice, message: "成功しました"))

      expect(page).to have_text("成功しました")
    end

    it "role=alertが設定される" do
      render_inline(described_class.new(type: :notice, message: "成功しました"))

      expect(page).to have_css("[role='alert']")
    end

    it "Stimulusコントローラーが設定される" do
      render_inline(described_class.new(type: :notice, message: "成功しました"))

      expect(page).to have_css("[data-controller='flash']")
    end
  end

  describe "メッセージタイプ" do
    context "noticeの場合" do
      it "成功スタイルが適用される" do
        render_inline(described_class.new(type: :notice, message: "成功"))

        expect(page).to have_css(".flash-notice")
      end

      it "成功アイコンが表示される" do
        render_inline(described_class.new(type: :notice, message: "成功"))

        expect(page).to have_css("svg")
      end
    end

    context "alertの場合" do
      it "警告スタイルが適用される" do
        render_inline(described_class.new(type: :alert, message: "警告"))

        expect(page).to have_css(".flash-alert")
      end
    end

    context "errorの場合" do
      it "エラースタイルが適用される" do
        render_inline(described_class.new(type: :error, message: "エラー"))

        expect(page).to have_css(".flash-error")
      end
    end

    context "infoの場合" do
      it "情報スタイルが適用される" do
        render_inline(described_class.new(type: :info, message: "情報"))

        expect(page).to have_css(".flash-info")
      end
    end
  end

  describe "閉じるボタン" do
    it "閉じるボタンが表示される" do
      render_inline(described_class.new(type: :notice, message: "成功"))

      expect(page).to have_css("[data-action*='flash#dismiss']")
    end

    it "aria-labelが設定される" do
      render_inline(described_class.new(type: :notice, message: "成功"))

      expect(page).to have_css("[aria-label='閉じる']")
    end

    it "dismissibleがfalseの場合、閉じるボタンが非表示" do
      render_inline(described_class.new(type: :notice, message: "成功", dismissible: false))

      expect(page).not_to have_css("[data-action*='flash#dismiss']")
    end
  end

  describe "自動非表示" do
    it "デフォルトの自動非表示時間が設定される" do
      render_inline(described_class.new(type: :notice, message: "成功"))

      expect(page).to have_css("[data-flash-auto-dismiss-value='5000']")
    end

    it "カスタム自動非表示時間を設定できる" do
      render_inline(described_class.new(type: :notice, message: "成功", auto_dismiss_ms: 3000))

      expect(page).to have_css("[data-flash-auto-dismiss-value='3000']")
    end

    it "自動非表示を無効にできる" do
      render_inline(described_class.new(type: :notice, message: "成功", auto_dismiss_ms: 0))

      expect(page).to have_css("[data-flash-auto-dismiss-value='0']")
    end
  end

  describe "複数メッセージの表示" do
    it "複数のコンポーネントをレンダリングできる" do
      render_inline(described_class.new(type: :notice, message: "成功しました"))
      first_html = page.native.inner_html

      render_inline(described_class.new(type: :alert, message: "警告です"))
      second_html = page.native.inner_html

      expect(first_html).to include("成功しました")
      expect(second_html).to include("警告です")
    end
  end

  describe "空メッセージ" do
    it "空のメッセージではレンダリングしない" do
      component = described_class.new(type: :notice, message: "")

      expect(component.render?).to be false
    end

    it "nilメッセージではレンダリングしない" do
      component = described_class.new(type: :notice, message: nil)

      expect(component.render?).to be false
    end
  end
end
