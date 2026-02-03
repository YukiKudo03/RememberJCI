# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Learner Dashboard Countdown", type: :request do
  let(:learner) { create(:user, :learner) }
  let(:teacher) { create(:user, :teacher) }
  let(:text) { create(:text, created_by: teacher) }

  before { sign_in learner }

  describe "GET / (学習者ダッシュボード)" do
    context "期限が3日後のアサインメントの場合" do
      let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher, deadline: 3.days.from_now) }

      it "残り日数が表示される" do
        get root_path
        expect(response.body).to include("あと3日")
      end
    end

    context "期限が1日後のアサインメントの場合" do
      let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher, deadline: 1.day.from_now) }

      it "残り日数が表示される" do
        get root_path
        expect(response.body).to include("あと1日")
      end
    end

    context "期限が今日のアサインメントの場合" do
      let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher, deadline: Time.current.end_of_day) }

      it "今日が期限であることが表示される" do
        get root_path
        expect(response.body).to include("今日が期限")
      end
    end

    context "期限切れのアサインメントの場合" do
      let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher, deadline: 2.days.ago) }

      it "期限切れが表示される" do
        get root_path
        expect(response.body).to include("期限切れ")
      end
    end

    context "期限なしのアサインメントの場合" do
      let!(:assignment) { create(:assignment, :to_user, user: learner, text: text, assigned_by: teacher, deadline: nil) }

      it "残り日数は表示されない" do
        get root_path
        expect(response.body).not_to include("あと")
        expect(response.body).not_to include("今日が期限")
      end
    end
  end
end
