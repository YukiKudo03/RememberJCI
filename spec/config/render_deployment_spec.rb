# frozen_string_literal: true

require "rails_helper"
require "yaml"

RSpec.describe "Renderデプロイ設定", type: :config do
  describe "render.yaml" do
    let(:render_yaml_path) { Rails.root.join("render.yaml") }
    let(:render_config) { YAML.load_file(render_yaml_path) }

    it "render.yamlが存在する" do
      expect(File.exist?(render_yaml_path)).to be true
    end

    describe "Webサービス設定" do
      let(:web_service) { render_config["services"].find { |s| s["type"] == "web" } }

      it "Webサービスが定義されている" do
        expect(web_service).not_to be_nil
      end

      it "サービス名が設定されている" do
        expect(web_service["name"]).to eq("rememberit")
      end

      it "Ruby環境が設定されている" do
        expect(web_service["env"]).to eq("ruby")
      end

      it "ビルドコマンドが設定されている" do
        expect(web_service["buildCommand"]).to be_present
      end

      it "スタートコマンドがPumaを使用している" do
        expect(web_service["startCommand"]).to include("puma")
      end

      it "必要な環境変数が設定されている" do
        env_keys = web_service["envVars"].map { |e| e["key"] }
        expect(env_keys).to include("RAILS_MASTER_KEY")
        expect(env_keys).to include("DATABASE_URL")
      end
    end

    describe "データベース設定" do
      let(:databases) { render_config["databases"] }

      it "データベースが定義されている" do
        expect(databases).not_to be_nil
        expect(databases).not_to be_empty
      end

      it "データベース名が設定されている" do
        db = databases.first
        expect(db["name"]).to be_present
      end
    end
  end

  describe "bin/render-build.sh" do
    let(:build_script_path) { Rails.root.join("bin", "render-build.sh") }
    let(:build_script_content) { File.read(build_script_path) }

    it "ビルドスクリプトが存在する" do
      expect(File.exist?(build_script_path)).to be true
    end

    it "ビルドスクリプトが実行可能" do
      expect(File.executable?(build_script_path)).to be true
    end

    it "bundle installが含まれている" do
      expect(build_script_content).to include("bundle install")
    end

    it "アセットプリコンパイルが含まれている" do
      expect(build_script_content).to include("assets:precompile")
    end

    it "データベースマイグレーションが含まれている" do
      # db:prepare は db:create + db:migrate を兼ねる。Render deploy では
      # 初回は DB create が必要、2回目以降は migrate だけで済むので prepare が適切。
      expect(build_script_content).to match(/db:(prepare|migrate)/)
    end
  end
end
