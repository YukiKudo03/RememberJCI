# spec/models/text_spec.rb
require 'rails_helper'

RSpec.describe Text, type: :model do
  describe "バリデーション" do
    context "必須項目" do
      it "タイトルがない場合は無効" do
        text = build(:text, title: nil)
        expect(text).not_to be_valid
      end

      it "内容がない場合は無効" do
        text = build(:text, content: nil)
        expect(text).not_to be_valid
      end
    end
  end

  describe "難易度（difficulty）" do
    it "easy, medium, hardの3段階がある" do
      expect(Text.difficulties.keys).to contain_exactly("easy", "medium", "hard")
    end

    it "デフォルトはmedium" do
      text = create(:text)
      expect(text).to be_medium
    end
  end

  describe "関連" do
    it { is_expected.to belong_to(:created_by).class_name("User") }
    it { is_expected.to have_many(:assignments).dependent(:destroy) }
    it { is_expected.to have_many(:learning_progresses).dependent(:destroy) }
    it { is_expected.to have_many(:tests).dependent(:destroy) }
  end

  describe "#word_count" do
    it "テキストの単語数を返す" do
      text = build(:text, content: "これは テスト 文章 です")
      expect(text.word_count).to eq(4)
    end
  end
end
