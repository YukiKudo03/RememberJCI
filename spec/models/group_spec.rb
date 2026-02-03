# spec/models/group_spec.rb
require 'rails_helper'

RSpec.describe Group, type: :model do
  describe "バリデーション" do
    context "必須項目" do
      it "名前がない場合は無効" do
        group = build(:group, name: nil)
        expect(group).not_to be_valid
        expect(group.errors[:name]).to include("を入力してください")
      end
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:group_members).dependent(:destroy) }
    it { is_expected.to have_many(:members).through(:group_members).source(:user) }
    it { is_expected.to have_many(:assignments).dependent(:destroy) }
  end

  describe "#add_member" do
    let(:group) { create(:group) }
    let(:user) { create(:user) }

    context "ユーザーがまだメンバーでない場合" do
      it "メンバーとして追加される" do
        expect { group.add_member(user) }.to change { group.members.count }.by(1)
      end
    end

    context "ユーザーが既にメンバーの場合" do
      before { group.add_member(user) }

      it "重複して追加されない" do
        expect { group.add_member(user) }.not_to change { group.members.count }
      end
    end
  end
end
