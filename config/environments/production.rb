require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings (ignored by Rake tasks).
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Turn on fragment caching in view templates.
  config.action_controller.perform_caching = true

  # Cache assets for far-future expiry since they are all digest stamped.
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.asset_host = "http://assets.example.com"

  # Store uploaded files on the local file system (see config/storage.yml for options).
  # 本番環境ではCloudflare R2やAWS S3を使用する場合はここを変更
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # Assume all access to the app is happening through a SSL-terminating reverse proxy.
  config.assume_ssl = true

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  config.force_ssl = true

  # Skip http-to-https redirect for the default health check endpoint.
  config.ssl_options = { redirect: { exclude: ->(request) { request.path == "/up" } } }

  # Log to STDOUT with the current request id as a default log tag.
  config.log_tags = [ :request_id ]
  config.logger   = ActiveSupport::TaggedLogging.logger(STDOUT)

  # Change to "debug" to log everything (including potentially personally-identifiable information!)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from clogging up the logs.
  config.silence_healthcheck_path = "/up"

  # Don't log any deprecations.
  config.active_support.report_deprecations = false

  # Replace the default in-process memory cache store with a durable alternative.
  # Solid Cacheを使用（PostgreSQLベース）
  config.cache_store = :solid_cache_store

  # Replace the default in-process and non-durable queuing backend for Active Job.
  # Solid Queueを使用（PostgreSQLベース）、Sidekiqを使用する場合は :sidekiq に変更
  config.active_job.queue_adapter = ENV.fetch("ACTIVE_JOB_ADAPTER", "solid_queue").to_sym

  # Solid Queue設定（使用する場合）
  if config.active_job.queue_adapter == :solid_queue
    config.solid_queue.connects_to = { database: { writing: :queue } }
  end

  # メール配信エラーを発生させる（本番環境では必要に応じて変更）
  config.action_mailer.raise_delivery_errors = true

  # Set host to be used by links generated in mailer templates.
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "localhost"), protocol: "https" }

  # Resendを使用したメール配信設定
  # RESEND_API_KEY環境変数が設定されている場合はResendを使用
  if ENV["RESEND_API_KEY"].present?
    config.action_mailer.delivery_method = :smtp
    config.action_mailer.smtp_settings = {
      address: "smtp.resend.com",
      port: 587,
      user_name: "resend",
      password: ENV["RESEND_API_KEY"],
      authentication: :plain,
      enable_starttls_auto: true
    }
  else
    # フォールバック: SMTPサーバー設定
    config.action_mailer.smtp_settings = {
      user_name: Rails.application.credentials.dig(:smtp, :user_name),
      password: Rails.application.credentials.dig(:smtp, :password),
      address: ENV.fetch("SMTP_ADDRESS", "smtp.example.com"),
      port: ENV.fetch("SMTP_PORT", 587).to_i,
      authentication: :plain,
      enable_starttls_auto: true
    }
  end

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation cannot be found).
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production.
  config.active_record.attributes_for_inspect = [ :id ]

  # Enable DNS rebinding protection and other `Host` header attacks.
  # 許可するホストを環境変数から設定
  config.hosts = ENV.fetch("ALLOWED_HOSTS", "").split(",").map(&:strip)
  config.hosts << ENV.fetch("APP_HOST", "localhost")
  config.hosts << /.*\.onrender\.com/ if ENV["RENDER"].present? # Render.comのホスト許可

  # Skip DNS rebinding protection for the default health check endpoint.
  config.host_authorization = { exclude: ->(request) { request.path == "/up" } }

  # Action Cableの設定（WebSocket使用時）
  # config.action_cable.url = "wss://#{ENV.fetch('APP_HOST', 'localhost')}/cable"
  # config.action_cable.allowed_request_origins = [
  #   "https://#{ENV.fetch('APP_HOST', 'localhost')}"
  # ]
end
