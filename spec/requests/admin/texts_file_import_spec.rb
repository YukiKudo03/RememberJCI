# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Texts File Import", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:txt_file_path) { Rails.root.join("spec/fixtures/files/sample.txt") }
  let(:pdf_file_path) { Rails.root.join("spec/fixtures/files/sample.pdf") }

  before { sign_in admin }

  describe "GET /admin/texts/new" do
    it "ファイルアップロードフィールドが表示される" do
      get new_admin_text_path
      expect(response.body).to include("ファイルからインポート")
    end

    it "対応フォーマットの説明が表示される" do
      get new_admin_text_path
      expect(response.body).to include("TXT")
      expect(response.body).to include("PDF")
    end
  end

  describe "POST /admin/texts（ファイルインポート付き）" do
    context "TXTファイルをアップロードした場合" do
      let(:txt_file) { Rack::Test::UploadedFile.new(txt_file_path, "text/plain") }

      it "テキストが作成される" do
        expect {
          post admin_texts_path, params: {
            text: { title: "インポートテスト", content: "", category: "一般", difficulty: "medium", import_file: txt_file }
          }
        }.to change(Text, :count).by(1)
      end

      it "ファイルの内容がcontentに設定される" do
        post admin_texts_path, params: {
          text: { title: "インポートテスト", content: "", category: "一般", difficulty: "medium", import_file: txt_file }
        }
        expect(Text.last.content).to include("これはサンプルテキストファイルです。")
      end
    end

    context "PDFファイルをアップロードした場合" do
      let(:pdf_file) { Rack::Test::UploadedFile.new(pdf_file_path, "application/pdf") }

      it "ファイルの内容がcontentに設定される" do
        post admin_texts_path, params: {
          text: { title: "PDFインポート", content: "", category: "一般", difficulty: "medium", import_file: pdf_file }
        }
        expect(Text.last.content).to include("Hello PDF World")
      end
    end

    context "ファイルなしで通常作成した場合" do
      it "通常通りcontentが使用される" do
        post admin_texts_path, params: {
          text: { title: "通常テキスト", content: "手動入力の内容", category: "一般", difficulty: "medium" }
        }
        expect(Text.last.content).to eq("手動入力の内容")
      end
    end
  end
end
