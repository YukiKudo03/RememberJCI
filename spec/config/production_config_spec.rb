# frozen_string_literal: true

require "rails_helper"

RSpec.describe "本番環境設定", type: :config do
  # 本番環境設定ファイルを直接読み込んでテスト
  let(:production_config_path) { Rails.root.join("config", "environments", "production.rb") }
  let(:production_config_content) { File.read(production_config_path) }

  describe "セキュリティ設定" do
    it "SSL強制が有効" do
      expect(production_config_content).to include("config.force_ssl = true")
    end

    it "SSL前提が有効" do
      expect(production_config_content).to include("config.assume_ssl = true")
    end
  end

  describe "キャッシュ設定" do
    it "フラグメントキャッシュが有効" do
      expect(production_config_content).to include("config.action_controller.perform_caching = true")
    end

    it "キャッシュストアが設定されている" do
      expect(production_config_content).to match(/config\.cache_store\s*=/)
    end
  end

  describe "ログ設定" do
    it "ログがSTDOUTに出力される" do
      expect(production_config_content).to include("ActiveSupport::TaggedLogging.logger(STDOUT)")
    end

    it "リクエストIDがログタグに含まれる" do
      expect(production_config_content).to include(":request_id")
    end

    it "ヘルスチェックパスが静音化されている" do
      expect(production_config_content).to include('config.silence_healthcheck_path = "/up"')
    end
  end

  describe "メール設定" do
    it "メールホスト設定が環境変数から取得される" do
      expect(production_config_content).to include('ENV.fetch("APP_HOST"')
    end
  end

  describe "Active Job設定" do
    it "ジョブアダプターが設定されている" do
      expect(production_config_content).to match(/config\.active_job\.queue_adapter\s*=/)
    end
  end

  describe "i18n設定" do
    it "フォールバックが有効" do
      expect(production_config_content).to include("config.i18n.fallbacks = true")
    end
  end

  describe "パフォーマンス設定" do
    it "eager loadingが有効" do
      expect(production_config_content).to include("config.eager_load = true")
    end

    it "リロードが無効" do
      expect(production_config_content).to include("config.enable_reloading = false")
    end
  end

  describe "ホスト設定" do
    it "ホスト制限が設定されている" do
      expect(production_config_content).to include("config.hosts")
    end
  end
end
