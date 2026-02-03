# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Rack Attack", type: :request do
  before do
    # テスト前にRack::Attackのキャッシュをクリア
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.reset!
  end

  describe "ログイン試行のスロットリング" do
    let(:user) { create(:user, email: "test@example.com") }

    it "同一IPから短時間に多数のログイン試行をブロックする" do
      20.times do
        post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
      end

      post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
      expect(response).to have_http_status(:too_many_requests)
    end

    it "制限内のリクエストは許可される" do
      post user_session_path, params: { user: { email: "test@example.com", password: "wrong" } }
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  describe "パスワードリセットのスロットリング" do
    it "同一IPから短時間に多数のパスワードリセット試行をブロックする" do
      20.times do
        post user_password_path, params: { user: { email: "test@example.com" } }
      end

      post user_password_path, params: { user: { email: "test@example.com" } }
      expect(response).to have_http_status(:too_many_requests)
    end
  end

  describe "一般リクエストのスロットリング" do
    before do
      @user = create(:user)
      sign_in @user
    end

    it "短時間に大量リクエストをブロックする" do
      300.times do
        get root_path
      end

      get root_path
      expect(response).to have_http_status(:too_many_requests)
    end

    it "通常のリクエストは許可される" do
      get root_path
      expect(response).not_to have_http_status(:too_many_requests)
    end
  end

  describe "Rack::Attackの設定" do
    it "Rack::Attackが有効である" do
      expect(Rails.application.middleware).to include(Rack::Attack)
    end
  end
end
