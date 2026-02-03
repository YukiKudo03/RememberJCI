# frozen_string_literal: true

require "rails_helper"

RSpec.describe Users::CsvImportService do
  describe "#call" do
    let(:service) { described_class.new(csv_content) }
    let(:result) { service.call }

    context "有効なCSVデータの場合" do
      let(:csv_content) do
        <<~CSV
          email,name,role,password
          user1@example.com,ユーザー1,learner,password123
          user2@example.com,ユーザー2,teacher,password456
          user3@example.com,ユーザー3,admin,password789
        CSV
      end

      it "成功を返す" do
        expect(result.success?).to be true
      end

      it "ユーザーが作成される" do
        expect { service.call }.to change(User, :count).by(3)
      end

      it "正しい属性でユーザーが作成される" do
        result
        user = User.find_by(email: "user1@example.com")
        expect(user.name).to eq("ユーザー1")
        expect(user).to be_learner
      end

      it "インポートされたユーザー数が返される" do
        expect(result.imported_count).to eq(3)
      end

      it "エラーがない" do
        expect(result.errors).to be_empty
      end

      it "各ユーザーに招待メールが送信される" do
        expect {
          service.call
        }.to have_enqueued_mail(UserMailer, :welcome).exactly(3).times
      end
    end

    context "パスワードが省略されている場合" do
      let(:csv_content) do
        <<~CSV
          email,name,role
          user@example.com,ユーザー,learner
        CSV
      end

      it "デフォルトパスワードが設定される" do
        result
        user = User.find_by(email: "user@example.com")
        expect(user).to be_present
        expect(user.valid_password?("changeme123")).to be true
      end
    end

    context "roleが省略されている場合" do
      let(:csv_content) do
        <<~CSV
          email,name,password
          user@example.com,ユーザー,password123
        CSV
      end

      it "デフォルトでlearnerが設定される" do
        result
        user = User.find_by(email: "user@example.com")
        expect(user).to be_learner
      end
    end

    context "無効なデータが含まれる場合" do
      let(:csv_content) do
        <<~CSV
          email,name,role,password
          valid@example.com,有効ユーザー,learner,password123
          ,名前のみ,learner,password123
          invalid-email,無効メール,learner,password123
        CSV
      end

      it "有効なデータはインポートされる" do
        expect { service.call }.to change(User, :count).by(1)
      end

      it "エラーが記録される" do
        expect(result.errors.count).to eq(2)
      end

      it "エラーに行番号が含まれる" do
        expect(result.errors.first).to include("行")
      end
    end

    context "重複するメールアドレスがある場合" do
      let!(:existing_user) { create(:user, email: "existing@example.com") }
      let(:csv_content) do
        <<~CSV
          email,name,role,password
          existing@example.com,重複ユーザー,learner,password123
          new@example.com,新規ユーザー,learner,password123
        CSV
      end

      it "重複はスキップされる" do
        expect { service.call }.to change(User, :count).by(1)
      end

      it "重複エラーが記録される" do
        expect(result.errors.count).to eq(1)
        expect(result.errors.first).to include("existing@example.com")
      end
    end

    context "空のCSVの場合" do
      let(:csv_content) { "" }

      it "エラーを返す" do
        expect(result.success?).to be false
      end

      it "エラーメッセージが含まれる" do
        expect(result.errors).to include("CSVデータが空です")
      end
    end

    context "ヘッダーのみの場合" do
      let(:csv_content) do
        <<~CSV
          email,name,role,password
        CSV
      end

      it "インポート数が0" do
        expect(result.imported_count).to eq(0)
      end
    end

    context "無効なロールが指定された場合" do
      let(:csv_content) do
        <<~CSV
          email,name,role,password
          user@example.com,ユーザー,invalid_role,password123
        CSV
      end

      it "エラーが記録される" do
        expect(result.errors.count).to eq(1)
      end
    end

    context "BOM付きUTF-8の場合" do
      let(:csv_content) do
        "\xEF\xBB\xBF" + <<~CSV
          email,name,role,password
          user@example.com,ユーザー,learner,password123
        CSV
      end

      it "正常にインポートできる" do
        expect(result.success?).to be true
        expect(result.imported_count).to eq(1)
      end
    end
  end

  describe ".import_from_file" do
    let(:file) { fixture_file_upload("users.csv", "text/csv") }

    before do
      # テスト用CSVファイルを作成
      FileUtils.mkdir_p(Rails.root.join("spec", "fixtures", "files"))
      File.write(
        Rails.root.join("spec", "fixtures", "files", "users.csv"),
        "email,name,role,password\ntest@example.com,テスト,learner,password123"
      )
    end

    after do
      FileUtils.rm_f(Rails.root.join("spec", "fixtures", "files", "users.csv"))
    end

    it "ファイルからインポートできる" do
      result = described_class.import_from_file(file)
      expect(result.success?).to be true
    end
  end
end
