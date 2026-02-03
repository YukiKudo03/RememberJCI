# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Content Security Policy", type: :request do
  describe "CSPヘッダー" do
    before do
      # テスト用にユーザーを作成してログイン
      @user = create(:user)
      sign_in @user
    end

    it "CSPヘッダーが設定される" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to be_present
    end

    it "default-srcが:selfに設定される" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("default-src 'self'")
    end

    it "script-srcが:selfを含む" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("script-src 'self'")
    end

    it "style-srcが:selfと:unsafe-inlineを含む" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("style-src 'self'")
      expect(csp).to include("'unsafe-inline'")
    end

    it "img-srcが:selfと:dataを含む" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("img-src 'self'")
      expect(csp).to include("data:")
    end

    it "font-srcが:selfを含む" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("font-src 'self'")
    end

    it "object-srcが:noneに設定される" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("object-src 'none'")
    end

    it "frame-ancestorsが:selfに設定される" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("frame-ancestors 'self'")
    end

    it "base-uriが:selfに設定される" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("base-uri 'self'")
    end

    it "media-srcが:selfとblob:を含む" do
      get root_path
      csp = response.headers["Content-Security-Policy"]
      expect(csp).to include("media-src 'self'")
      expect(csp).to include("blob:")
    end
  end
end
