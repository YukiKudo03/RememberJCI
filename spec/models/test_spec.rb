# spec/models/test_spec.rb
require 'rails_helper'

RSpec.describe Test, type: :model do
  describe "バリデーション" do
    it { is_expected.to validate_presence_of(:test_type) }
  end

  describe "テストタイプ（test_type）" do
    it "typingとaudioの2種類がある" do
      expect(Test.test_types.keys).to contain_exactly("typing", "audio")
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:text) }
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:submissions).class_name("TestSubmission").dependent(:destroy) }
  end

  describe "#available?" do
    context "期間が設定されている場合" do
      it "期間内であればtrueを返す" do
        test = build(:test,
          available_from: 1.day.ago,
          available_until: 1.day.from_now)
        expect(test).to be_available
      end

      it "期間外であればfalseを返す" do
        test = build(:test,
          available_from: 1.day.from_now,
          available_until: 2.days.from_now)
        expect(test).not_to be_available
      end
    end

    context "期間が設定されていない場合" do
      it "trueを返す" do
        test = build(:test, available_from: nil, available_until: nil)
        expect(test).to be_available
      end
    end
  end
end
