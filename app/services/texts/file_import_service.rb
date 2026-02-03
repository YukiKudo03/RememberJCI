# frozen_string_literal: true

module Texts
  # TXTまたはPDFファイルからテキスト内容を抽出するサービス
  #
  # 要件参照: FR-13（ファイルからのテキストインポート）
  #
  # @example
  #   result = Texts::FileImportService.new(uploaded_file).call
  #   if result.success?
  #     text.content = result.content
  #   else
  #     flash[:alert] = result.error
  #   end
  class FileImportService
    Result = Struct.new(:content, :error, keyword_init: true) do
      def success?
        error.nil?
      end
    end

    SUPPORTED_EXTENSIONS = %w[.txt .pdf].freeze

    def initialize(file)
      @file = file
    end

    def call
      return Result.new(error: "ファイルが指定されていません") if @file.nil?

      extension = File.extname(original_filename).downcase

      unless SUPPORTED_EXTENSIONS.include?(extension)
        return Result.new(error: "サポートされていないファイル形式です。TXTまたはPDFファイルをアップロードしてください。")
      end

      content = extract_content(extension)

      if content.blank?
        return Result.new(error: "ファイルが空です")
      end

      Result.new(content: content)
    rescue PDF::Reader::MalformedPDFError
      Result.new(error: "PDFファイルの読み取りに失敗しました。ファイルが破損している可能性があります。")
    rescue StandardError => e
      Result.new(error: "ファイルの読み取りに失敗しました: #{e.message}")
    end

    private

    def original_filename
      @file.original_filename
    end

    def extract_content(extension)
      case extension
      when ".txt"
        extract_from_txt
      when ".pdf"
        extract_from_pdf
      end
    end

    def extract_from_txt
      @file.read.force_encoding("UTF-8")
    end

    def extract_from_pdf
      reader = PDF::Reader.new(@file.tempfile.path)
      reader.pages.map(&:text).join("\n").strip
    end
  end
end
