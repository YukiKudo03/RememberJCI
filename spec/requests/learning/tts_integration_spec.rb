# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Learning TTS Integration", type: :request do
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: teacher, content: "これは読み上げテスト用のテキストです。") }

  before do
    create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
    sign_in learner
  end

  describe "GET /learning/texts/:id/practice" do
    it "読み上げボタンが表示される" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include("data-action=\"click->tts#speak\"")
    end

    it "TTSコントローラーのdata属性がある" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include('data-controller="tts"')
    end

    it "読み上げ対象テキストがdata属性に設定される" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include('data-tts-text-value')
    end

    it "読み上げボタンにaria-labelが設定される" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include('aria-label="テキストを読み上げ"')
    end

    it "停止ボタンが存在する" do
      get practice_learning_text_path(text, level: 0)
      expect(response.body).to include('data-action="click->tts#stop"')
    end
  end
end
