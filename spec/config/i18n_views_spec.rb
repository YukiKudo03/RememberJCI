# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ビュー翻訳", type: :config do
  describe "ダッシュボード翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "ダッシュボードタイトルが翻訳されている" do
        expect(I18n.t("dashboard.title")).to eq("ダッシュボード")
      end

      it "ダッシュボードウェルカムメッセージが翻訳されている" do
        expect(I18n.t("dashboard.welcome")).to eq("ようこそ")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "ダッシュボードタイトルが翻訳されている" do
        expect(I18n.t("dashboard.title")).to eq("Dashboard")
      end

      it "ダッシュボードウェルカムメッセージが翻訳されている" do
        expect(I18n.t("dashboard.welcome")).to eq("Welcome")
      end
    end
  end

  describe "テキスト管理翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "テキスト一覧タイトルが翻訳されている" do
        expect(I18n.t("texts.index.title")).to eq("テキスト一覧")
      end

      it "テキスト新規作成が翻訳されている" do
        expect(I18n.t("texts.new.title")).to eq("テキスト新規作成")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "テキスト一覧タイトルが翻訳されている" do
        expect(I18n.t("texts.index.title")).to eq("Texts")
      end

      it "テキスト新規作成が翻訳されている" do
        expect(I18n.t("texts.new.title")).to eq("New Text")
      end
    end
  end

  describe "グループ管理翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "グループ一覧タイトルが翻訳されている" do
        expect(I18n.t("groups.index.title")).to eq("グループ一覧")
      end

      it "メンバー追加が翻訳されている" do
        expect(I18n.t("groups.members.add")).to eq("メンバー追加")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "グループ一覧タイトルが翻訳されている" do
        expect(I18n.t("groups.index.title")).to eq("Groups")
      end

      it "メンバー追加が翻訳されている" do
        expect(I18n.t("groups.members.add")).to eq("Add Member")
      end
    end
  end

  describe "テスト管理翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "テスト一覧タイトルが翻訳されている" do
        expect(I18n.t("tests.index.title")).to eq("テスト一覧")
      end

      it "テスト結果が翻訳されている" do
        expect(I18n.t("tests.result.title")).to eq("テスト結果")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "テスト一覧タイトルが翻訳されている" do
        expect(I18n.t("tests.index.title")).to eq("Tests")
      end

      it "テスト結果が翻訳されている" do
        expect(I18n.t("tests.result.title")).to eq("Test Result")
      end
    end
  end

  describe "分析翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "分析タイトルが翻訳されている" do
        expect(I18n.t("analytics.title")).to eq("分析")
      end

      it "グループ分析が翻訳されている" do
        expect(I18n.t("analytics.groups.title")).to eq("グループ分析")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "分析タイトルが翻訳されている" do
        expect(I18n.t("analytics.title")).to eq("Analytics")
      end

      it "グループ分析が翻訳されている" do
        expect(I18n.t("analytics.groups.title")).to eq("Group Analytics")
      end
    end
  end

  describe "学習モジュール翻訳" do
    describe "日本語" do
      before { I18n.locale = :ja }
      after { I18n.locale = I18n.default_locale }

      it "学習開始が翻訳されている" do
        expect(I18n.t("learning.start")).to eq("学習を開始")
      end

      it "練習モードが翻訳されている" do
        expect(I18n.t("learning.practice_mode")).to eq("練習モード")
      end
    end

    describe "英語" do
      before { I18n.locale = :en }
      after { I18n.locale = I18n.default_locale }

      it "学習開始が翻訳されている" do
        expect(I18n.t("learning.start")).to eq("Start Learning")
      end

      it "練習モードが翻訳されている" do
        expect(I18n.t("learning.practice_mode")).to eq("Practice Mode")
      end
    end
  end
end
