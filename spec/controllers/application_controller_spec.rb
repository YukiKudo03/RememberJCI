# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationController, type: :controller do
  include Devise::Test::ControllerHelpers

  describe "Pundit認可チェック強制" do
    it "verify_authorizedがafter_actionとして設定されている" do
      filters = described_class._process_action_callbacks.select { |c| c.filter == :verify_authorized }
      expect(filters).not_to be_empty
    end

    it "verify_policy_scopedがafter_actionとして設定されている" do
      filters = described_class._process_action_callbacks.select { |c| c.filter == :verify_policy_scoped }
      expect(filters).not_to be_empty
    end
  end

  describe "グローバル認証" do
    controller do
      skip_after_action :verify_authorized
      skip_after_action :verify_policy_scoped

      def index
        render plain: "OK"
      end
    end

    it "authenticate_user!がbefore_actionとして設定されている" do
      filters = described_class._process_action_callbacks.select { |c| c.filter == :authenticate_user! }
      expect(filters).not_to be_empty
    end

    context "未認証ユーザー" do
      it "ログインページにリダイレクトされる" do
        get :index
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "認証済みユーザー" do
      let(:user) { create(:user) }

      it "アクセスが許可される" do
        sign_in user
        get :index
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
