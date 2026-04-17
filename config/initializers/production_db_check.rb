# frozen_string_literal: true

# Fail fast with a clear message if production boots without DATABASE_URL.
# Without this, Rails silently falls back to unix-socket Postgres connection
# ("/var/run/postgresql/.s.PGSQL.5432") which produces a confusing error that
# reads like the app is trying to find a local Postgres rather than the
# missing env var it actually is.
#
# Render wires DATABASE_URL via `fromDatabase: { name: rememberit-db,
# property: connectionString }` in render.yaml. If that resolution fails —
# Blueprint not synced, database service not yet available, or manual service
# creation bypassing the Blueprint — the var is empty and we hit the socket
# error. This initializer turns that into an obvious "DATABASE_URL not set"
# boot failure so the operator knows exactly where to look.
if Rails.env.production? && ENV["DATABASE_URL"].to_s.strip.empty?
  raise <<~MSG
    ============================================================
    FATAL: DATABASE_URL is not set in production.

    Rails won't connect to the primary Postgres without it.
    Check your Render service Environment tab:

      1. Dashboard → rememberit service → Environment
      2. Verify DATABASE_URL exists and starts with "postgresql://"
      3. If missing, the Blueprint link to rememberit-db has not
         resolved. Either wait for the Postgres service to finish
         provisioning, trigger a manual Blueprint sync, or copy the
         Internal Database URL from the rememberit-db service and
         paste it into DATABASE_URL manually.

    Current environment:
      RAILS_ENV = #{ENV['RAILS_ENV'].inspect}
      RENDER    = #{ENV['RENDER'].inspect}
    ============================================================
  MSG
end
