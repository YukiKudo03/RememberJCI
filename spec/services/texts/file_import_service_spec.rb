# frozen_string_literal: true

require "rails_helper"

RSpec.describe Texts::FileImportService do
  let(:txt_file_path) { Rails.root.join("spec/fixtures/files/sample.txt") }
  let(:pdf_file_path) { Rails.root.join("spec/fixtures/files/sample.pdf") }

  describe "#call" do
    context "TXTファイルの場合" do
      let(:file) { Rack::Test::UploadedFile.new(txt_file_path, "text/plain") }
      let(:service) { described_class.new(file) }

      it "テキスト内容を抽出できる" do
        result = service.call
        expect(result).to be_success
        expect(result.content).to include("これはサンプルテキストファイルです。")
      end

      it "複数行のテキストを正しく読み取る" do
        result = service.call
        expect(result.content).to include("暗記用のコンテンツがここに入ります。")
        expect(result.content).to include("しっかり覚えましょう。")
      end
    end

    context "PDFファイルの場合" do
      let(:file) { Rack::Test::UploadedFile.new(pdf_file_path, "application/pdf") }
      let(:service) { described_class.new(file) }

      it "テキスト内容を抽出できる" do
        result = service.call
        expect(result).to be_success
        expect(result.content).to include("Hello PDF World")
      end
    end

    context "サポートされていないファイル形式の場合" do
      let(:file) do
        # Create a temp file with unsupported extension
        tmpfile = Tempfile.new(["test", ".docx"])
        tmpfile.write("some content")
        tmpfile.rewind
        Rack::Test::UploadedFile.new(tmpfile.path, "application/vnd.openxmlformats-officedocument.wordprocessingml.document", false, original_filename: "test.docx")
      end

      let(:service) { described_class.new(file) }

      it "エラーを返す" do
        result = service.call
        expect(result).not_to be_success
        expect(result.error).to include("サポートされていないファイル形式")
      end
    end

    context "空のファイルの場合" do
      let(:file) do
        tmpfile = Tempfile.new(["empty", ".txt"])
        tmpfile.rewind
        Rack::Test::UploadedFile.new(tmpfile.path, "text/plain")
      end

      let(:service) { described_class.new(file) }

      it "エラーを返す" do
        result = service.call
        expect(result).not_to be_success
        expect(result.error).to include("ファイルが空です")
      end
    end

    context "ファイルがnilの場合" do
      let(:service) { described_class.new(nil) }

      it "エラーを返す" do
        result = service.call
        expect(result).not_to be_success
        expect(result.error).to include("ファイルが指定されていません")
      end
    end
  end
end
