# frozen_string_literal: true

# Rack::Attack configuration for rate limiting and throttling
# See: https://github.com/rack/rack-attack

class Rack::Attack
  # Use Rails cache as the store
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # === Throttle rules ===

  # General request throttle: 300 requests per 5 minutes per IP
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  # Login throttle: 20 attempts per 1 minute per IP
  throttle("logins/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path == "/users/sign_in" && req.post?
  end

  # Login throttle by email: 20 attempts per 1 minute per email
  throttle("logins/email", limit: 20, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.params.dig("user", "email")&.downcase&.strip
    end
  end

  # Password reset throttle: 20 attempts per 1 minute per IP
  throttle("password_resets/ip", limit: 20, period: 1.minute) do |req|
    req.ip if req.path == "/users/password" && req.post?
  end

  # === Custom response ===

  self.throttled_responder = lambda do |_request|
    [
      429,
      { "Content-Type" => "text/plain" },
      ["リクエスト数が制限を超えました。しばらくしてから再試行してください。\n"]
    ]
  end
end
