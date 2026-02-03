# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Sidekiq設定", type: :config do
  describe "設定ファイル" do
    it "sidekiq.ymlが存在する" do
      config_path = Rails.root.join("config", "sidekiq.yml")
      expect(File.exist?(config_path)).to be true
    end

    it "sidekiq initializerが存在する" do
      initializer_path = Rails.root.join("config", "initializers", "sidekiq.rb")
      expect(File.exist?(initializer_path)).to be true
    end
  end

  describe "Sidekiq gem" do
    it "sidekiqがロードされている" do
      expect(defined?(Sidekiq)).to be_truthy
    end
  end

  describe "キュー設定" do
    let(:sidekiq_config) { YAML.load_file(Rails.root.join("config", "sidekiq.yml")) }
    let(:queue_names) do
      queues = sidekiq_config[:queues] || sidekiq_config["queues"]
      # キューは [name, priority] 形式または文字列形式
      queues.map { |q| q.is_a?(Array) ? q.first : q }
    end

    it "defaultキューが設定されている" do
      expect(queue_names).to include("default")
    end

    it "mailerキューが設定されている" do
      expect(queue_names).to include("mailers")
    end

    it "gradingキューが設定されている" do
      expect(queue_names).to include("grading")
    end
  end
end
