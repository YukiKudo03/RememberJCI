# frozen_string_literal: true

require "csv"

module Users
  class CsvImportService
    Result = Struct.new(:success?, :imported_count, :errors, keyword_init: true)

    DEFAULT_PASSWORD = "changeme123"
    DEFAULT_ROLE = "learner"
    VALID_ROLES = %w[learner teacher admin].freeze

    def initialize(csv_content)
      @csv_content = sanitize_bom(csv_content.to_s)
      @errors = []
      @imported_count = 0
    end

    def call
      return empty_csv_error if @csv_content.blank?

      parse_and_import
      build_result
    end

    def self.import_from_file(file)
      content = file.read
      new(content).call
    end

    private

    def sanitize_bom(content)
      utf8_content = content.dup.force_encoding("UTF-8")
      utf8_content.sub(/\A\xEF\xBB\xBF/u, "")
    end

    def empty_csv_error
      Result.new(success?: false, imported_count: 0, errors: [ "CSVデータが空です" ])
    end

    def parse_and_import
      rows = CSV.parse(@csv_content, headers: true)
      rows.each.with_index(2) do |row, line_number|
        import_row(row, line_number)
      end
    rescue CSV::MalformedCSVError => e
      @errors << "CSVの形式が不正です: #{e.message}"
    end

    def import_row(row, line_number)
      return if row.to_h.values.all?(&:blank?)

      email = row["email"].to_s.strip
      name = row["name"].to_s.strip
      role = row["role"].to_s.strip.presence || DEFAULT_ROLE
      password = row["password"].to_s.strip.presence || DEFAULT_PASSWORD

      validate_and_create(email:, name:, role:, password:, line_number:)
    end

    def validate_and_create(email:, name:, role:, password:, line_number:)
      if email.blank?
        @errors << "行#{line_number}: メールアドレスが必要です"
        return
      end

      unless valid_email?(email)
        @errors << "行#{line_number}: メールアドレスの形式が不正です (#{email})"
        return
      end

      unless VALID_ROLES.include?(role)
        @errors << "行#{line_number}: 無効なロールです (#{role})"
        return
      end

      if User.exists?(email: email)
        @errors << "行#{line_number}: メールアドレスが既に登録されています (#{email})"
        return
      end

      create_user(email:, name:, role:, password:, line_number:)
    end

    def valid_email?(email)
      email.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
    end

    def create_user(email:, name:, role:, password:, line_number:)
      user = User.new(
        email: email,
        name: name,
        role: role,
        password: password,
        password_confirmation: password
      )

      if user.save
        UserMailer.welcome(user).deliver_later
        @imported_count += 1
      else
        @errors << "行#{line_number}: #{user.errors.full_messages.join(', ')}"
      end
    end

    def build_result
      Result.new(
        success?: @errors.empty?,
        imported_count: @imported_count,
        errors: @errors
      )
    end
  end
end
