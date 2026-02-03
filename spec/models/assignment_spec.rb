# spec/models/assignment_spec.rb
require 'rails_helper'

RSpec.describe Assignment, type: :model do
  describe "バリデーション" do
    context "割り当て先" do
      it "ユーザーもグループも指定されていない場合は無効" do
        assignment = build(:assignment, user: nil, group: nil)
        expect(assignment).not_to be_valid
        expect(assignment.errors[:base]).to include("ユーザーまたはグループを指定してください")
      end

      it "ユーザーが指定されている場合は有効" do
        assignment = build(:assignment, :to_user)
        expect(assignment).to be_valid
      end

      it "グループが指定されている場合は有効" do
        assignment = build(:assignment, :to_group)
        expect(assignment).to be_valid
      end
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:text) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:group).optional }
    it { is_expected.to belong_to(:assigned_by).class_name("User") }
  end

  describe "#overdue?" do
    context "期限が設定されている場合" do
      it "期限を過ぎていればtrueを返す" do
        assignment = build(:assignment, deadline: 1.day.ago)
        expect(assignment).to be_overdue
      end

      it "期限前であればfalseを返す" do
        assignment = build(:assignment, deadline: 1.day.from_now)
        expect(assignment).not_to be_overdue
      end
    end

    context "期限が設定されていない場合" do
      it "falseを返す" do
        assignment = build(:assignment, deadline: nil)
        expect(assignment).not_to be_overdue
      end
    end
  end
end
