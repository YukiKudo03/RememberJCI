# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#navigation_items_for_role" do
    context "管理者(admin)の場合" do
      it "管理者用のメニュー項目を返す" do
        items = helper.navigation_items_for_role("admin")

        expect(items).to be_an(Array)
        expect(items.length).to eq(4)
        expect(items.map { |i| i[:label] }).to eq(
          %w[ダッシュボード ユーザー管理 テキスト管理 グループ管理]
        )
      end
    end

    context "教師(teacher)の場合" do
      it "教師用のメニュー項目を返す" do
        items = helper.navigation_items_for_role("teacher")

        expect(items).to be_an(Array)
        expect(items.length).to eq(3)
        expect(items.map { |i| i[:label] }).to eq(
          %w[ダッシュボード グループ管理 テスト管理]
        )
      end
    end

    context "学習者(learner)の場合" do
      it "学習者用のメニュー項目を返す" do
        items = helper.navigation_items_for_role("learner")

        expect(items).to be_an(Array)
        expect(items.length).to eq(3)
        expect(items.map { |i| i[:label] }).to eq(
          %w[ダッシュボード 学習 テスト]
        )
      end
    end

    context "シンボルで指定した場合" do
      it "正しくメニュー項目を返す" do
        items = helper.navigation_items_for_role(:admin)

        expect(items.length).to eq(4)
        expect(items.first[:label]).to eq("ダッシュボード")
      end
    end
  end

  describe "#role_badge_class" do
    it "管理者には紫色のバッジクラスを返す" do
      expect(helper.role_badge_class("admin")).to eq("bg-purple-100 text-purple-800")
    end

    it "教師には青色のバッジクラスを返す" do
      expect(helper.role_badge_class("teacher")).to eq("bg-blue-100 text-blue-800")
    end

    it "学習者には緑色のバッジクラスを返す" do
      expect(helper.role_badge_class("learner")).to eq("bg-green-100 text-green-800")
    end
  end

  describe "#role_display_name" do
    it "管理者の日本語名を返す" do
      expect(helper.role_display_name("admin")).to eq("管理者")
    end

    it "教師の日本語名を返す" do
      expect(helper.role_display_name("teacher")).to eq("教師")
    end

    it "学習者の日本語名を返す" do
      expect(helper.role_display_name("learner")).to eq("学習者")
    end
  end
end
