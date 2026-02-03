# frozen_string_literal: true

require "rails_helper"

RSpec.describe AudioRecorderComponent, type: :component do
  describe "基本的なレンダリング" do
    it "レコーダーUIをレンダリングする" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-controller='audio-recorder']")
    end

    it "録音ボタンが表示される" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-target='recordButton']")
    end

    it "停止ボタンが表示される" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-target='stopButton']")
    end
  end

  describe "オプション設定" do
    it "最大録音時間を設定できる" do
      render_inline(described_class.new(max_duration_seconds: 300))

      expect(page).to have_css("[data-audio-recorder-max-duration-value='300']")
    end

    it "デフォルトの最大録音時間は180秒" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-max-duration-value='180']")
    end

    it "auto_submitを設定できる" do
      render_inline(described_class.new(auto_submit: true))

      expect(page).to have_css("[data-audio-recorder-auto-submit-value='true']")
    end

    it "target_inputを設定できる" do
      render_inline(described_class.new(target_input: "audio_data"))

      expect(page).to have_css("[data-audio-recorder-target-input-value='audio_data']")
    end
  end

  describe "再生機能" do
    it "再生ボタンが表示される" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-target='playButton']")
    end

    it "オーディオプレイヤーが存在する" do
      render_inline(described_class.new)

      expect(page).to have_css("audio[data-audio-recorder-target='audio']")
    end
  end

  describe "状態表示" do
    it "録音時間の表示エリアが存在する" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-target='timer']")
    end

    it "状態表示エリアが存在する" do
      render_inline(described_class.new)

      expect(page).to have_css("[data-audio-recorder-target='status']")
    end

    it "波形表示エリアが存在する" do
      render_inline(described_class.new(show_waveform: true))

      expect(page).to have_css("[data-audio-recorder-target='waveform']")
    end

    it "show_waveformがfalseの場合、波形エリアが非表示" do
      render_inline(described_class.new(show_waveform: false))

      expect(page).not_to have_css("[data-audio-recorder-target='waveform']")
    end
  end

  describe "スタイルバリアント" do
    it "デフォルトはnormalサイズ" do
      render_inline(described_class.new)

      expect(page).to have_css(".audio-recorder-normal")
    end

    it "compactサイズを指定できる" do
      render_inline(described_class.new(size: :compact))

      expect(page).to have_css(".audio-recorder-compact")
    end

    it "largeサイズを指定できる" do
      render_inline(described_class.new(size: :large))

      expect(page).to have_css(".audio-recorder-large")
    end
  end

  describe "隠しフィールド" do
    it "録音データ保存用の隠しフィールドが存在する" do
      render_inline(described_class.new)

      expect(page).to have_css("input[type='hidden'][data-audio-recorder-target='dataInput']", visible: :hidden)
    end

    it "フィールド名を指定できる" do
      render_inline(described_class.new(field_name: "submission[audio]"))

      expect(page).to have_css("input[name='submission[audio]']", visible: :hidden)
    end
  end

  describe "アクセシビリティ" do
    it "録音ボタンにaria-labelが設定される" do
      render_inline(described_class.new)

      expect(page).to have_css("[aria-label='録音開始']")
    end

    it "停止ボタンにaria-labelが設定される" do
      render_inline(described_class.new)

      expect(page).to have_css("[aria-label='録音停止']")
    end

    it "再生ボタンにaria-labelが設定される" do
      render_inline(described_class.new)

      expect(page).to have_css("[aria-label='再生']")
    end
  end

  describe "コールバック設定" do
    it "on_recording_startを設定できる" do
      render_inline(described_class.new(on_recording_start: "handleStart"))

      expect(page).to have_css("[data-audio-recorder-on-recording-start-value='handleStart']")
    end

    it "on_recording_stopを設定できる" do
      render_inline(described_class.new(on_recording_stop: "handleStop"))

      expect(page).to have_css("[data-audio-recorder-on-recording-stop-value='handleStop']")
    end
  end
end
