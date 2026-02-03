# spec/models/group_membership_spec.rb
require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe "バリデーション" do
    context "一意性制約" do
      it "同じユーザーは同じグループに2回追加できない" do
        group_membership = create(:group_membership)
        duplicate = build(:group_membership,
          user: group_membership.user,
          group: group_membership.group)
        expect(duplicate).not_to be_valid
      end
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end
end
