# frozen_string_literal: true

# Sidekiq設定
#
# 本ファイルはSidekiqのサーバー/クライアント両方の設定を行う
#
# 使用方法:
#   開発環境: bundle exec sidekiq
#   本番環境: REDIS_URL環境変数を設定してからsidekiqを起動
#
# 参考: https://github.com/sidekiq/sidekiq/wiki/Using-Redis

# Redis接続URL（環境変数から取得、デフォルトはローカルRedis）
redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/1")

# Sidekiqサーバー設定（ワーカープロセス用）
Sidekiq.configure_server do |config|
  config.redis = { url: redis_url }

  # ログレベル設定
  config.logger.level = Rails.env.production? ? Logger::INFO : Logger::DEBUG
end

# Sidekiqクライアント設定（ジョブをエンキューするプロセス用）
Sidekiq.configure_client do |config|
  config.redis = { url: redis_url }
end

# Sidekiq Web UI（管理画面）のルートマウントは routes.rb で設定
# 例: mount Sidekiq::Web => '/sidekiq'
