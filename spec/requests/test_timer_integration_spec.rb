# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Test Timer Integration", type: :request do
  let(:teacher) { create(:user, :teacher) }
  let(:learner) { create(:user, :learner) }
  let(:text) { create(:text, created_by: teacher) }

  before do
    create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher)
    sign_in learner
  end

  describe "GET /tests/:id/take（制限時間付きテスト）" do
    let(:test_record) { create(:test, :available_now, text: text, created_by: teacher, time_limit: 30) }

    it "TimerComponentが表示される" do
      get take_test_path(test_record)
      expect(response.body).to include('data-controller="timer"')
    end

    it "制限時間が秒数でdata属性に設定される" do
      get take_test_path(test_record)
      expect(response.body).to include('data-timer-duration-value="1800"')
    end

    it "タイマーが自動開始される" do
      get take_test_path(test_record)
      expect(response.body).to include('data-timer-auto-start-value="true"')
    end

    it "role=timerのアクセシビリティ属性がある" do
      get take_test_path(test_record)
      expect(response.body).to include('role="timer"')
    end

    it "aria-live=politeが設定される" do
      get take_test_path(test_record)
      expect(response.body).to include('aria-live="polite"')
    end
  end

  describe "GET /tests/:id/take（制限時間なしテスト）" do
    let(:test_record) { create(:test, :available_now, text: text, created_by: teacher, time_limit: nil) }

    it "TimerComponentが表示されない" do
      get take_test_path(test_record)
      expect(response.body).not_to include('data-controller="timer"')
    end
  end
end
