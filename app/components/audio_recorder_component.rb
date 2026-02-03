# frozen_string_literal: true

# AudioRecorderComponent - 音声録音用コンポーネント
#
# 要件参照: FR-52（音声入力のサポート）
#
# @example 基本的な使用
#   <%= render AudioRecorderComponent.new %>
#
# @example オプション付き
#   <%= render AudioRecorderComponent.new(
#     max_duration_seconds: 300,
#     auto_submit: true,
#     field_name: "submission[audio]",
#     size: :large
#   ) %>
#
class AudioRecorderComponent < ApplicationComponent
  SIZES = {
    compact: "audio-recorder-compact",
    normal: "audio-recorder-normal",
    large: "audio-recorder-large"
  }.freeze

  DEFAULT_MAX_DURATION = 180 # 3分

  # @param max_duration_seconds [Integer] 最大録音時間（秒）
  # @param auto_submit [Boolean] 録音停止時に自動送信するかどうか
  # @param target_input [String, nil] 録音データを設定する入力フィールドのID
  # @param field_name [String] 隠しフィールドの名前
  # @param size [Symbol] コンポーネントのサイズ（:compact, :normal, :large）
  # @param show_waveform [Boolean] 波形を表示するかどうか
  # @param on_recording_start [String, nil] 録音開始時のコールバック
  # @param on_recording_stop [String, nil] 録音停止時のコールバック
  def initialize(
    max_duration_seconds: DEFAULT_MAX_DURATION,
    auto_submit: false,
    target_input: nil,
    field_name: "audio_data",
    size: :normal,
    show_waveform: true,
    on_recording_start: nil,
    on_recording_stop: nil
  )
    @max_duration_seconds = max_duration_seconds
    @auto_submit = auto_submit
    @target_input = target_input
    @field_name = field_name
    @size = size
    @show_waveform = show_waveform
    @on_recording_start = on_recording_start
    @on_recording_stop = on_recording_stop
  end

  # サイズに応じたCSSクラス
  # @return [String]
  def size_classes
    SIZES[@size] || SIZES[:normal]
  end

  # 波形を表示するかどうか
  # @return [Boolean]
  def show_waveform?
    @show_waveform
  end

  # Stimulusコントローラー用のdata属性
  # @return [Hash]
  def stimulus_data
    data = {
      "controller" => "audio-recorder",
      "audio-recorder-max-duration-value" => @max_duration_seconds,
      "audio-recorder-auto-submit-value" => @auto_submit.to_s
    }

    data["audio-recorder-target-input-value"] = @target_input if @target_input
    data["audio-recorder-on-recording-start-value"] = @on_recording_start if @on_recording_start
    data["audio-recorder-on-recording-stop-value"] = @on_recording_stop if @on_recording_stop

    data
  end

  # フィールド名
  # @return [String]
  attr_reader :field_name
end
