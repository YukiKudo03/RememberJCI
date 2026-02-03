# frozen_string_literal: true

# spec/models/text_versioning_spec.rb
require "rails_helper"

RSpec.describe "Text versioning", type: :model do
  let(:admin) { create(:user, :admin) }
  let(:text) { create(:text, title: "初版タイトル", content: "初版の内容です", created_by: admin) }

  describe "has_paper_trail" do
    it "TextモデルがPaperTrailを使用している" do
      expect(Text.new).to respond_to(:versions)
    end

    it "テキスト作成時にバージョンが記録される" do
      expect(text.versions.count).to eq(1)
    end

    it "テキスト更新時にバージョンが記録される" do
      text.update!(title: "更新タイトル")
      expect(text.versions.count).to eq(2)
    end

    it "content変更時にバージョンが記録される" do
      text.update!(content: "更新された内容です")
      expect(text.versions.count).to eq(2)
    end

    it "以前のバージョンに復元できる" do
      original_title = text.title
      text.update!(title: "更新タイトル")
      text.paper_trail.previous_version.save!
      expect(text.reload.title).to eq(original_title)
    end
  end

  describe "バージョン履歴" do
    it "変更内容を確認できる" do
      text.update!(title: "更新タイトル")
      last_version = text.versions.last
      expect(last_version.changeset).to have_key("title")
    end

    it "変更者（whodunnit）を記録できる" do
      PaperTrail.request.whodunnit = admin.id.to_s
      text.update!(title: "更新タイトル")
      expect(text.versions.last.whodunnit).to eq(admin.id.to_s)
    end
  end
end
