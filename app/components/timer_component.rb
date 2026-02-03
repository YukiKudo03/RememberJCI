# frozen_string_literal: true

# TimerComponent - テスト用カウントダウンタイマーコンポーネント
#
# 要件参照: FR-54（制限時間付きテストのサポート）
#
# @example 基本的な使用
#   <%= render TimerComponent.new(duration_minutes: 30) %>
#
# @example オプション付き
#   <%= render TimerComponent.new(
#     duration_minutes: 30,
#     auto_start: true,
#     warning_threshold: 300,
#     danger_threshold: 60,
#     size: :large
#   ) %>
#
class TimerComponent < ApplicationComponent
  SIZES = {
    compact: "timer-compact text-sm",
    normal: "timer-normal text-base",
    large: "timer-large text-2xl font-bold"
  }.freeze

  # @param duration_minutes [Integer] タイマーの制限時間（分）
  # @param auto_start [Boolean] 自動開始するかどうか
  # @param warning_threshold [Integer] 警告表示を開始する残り秒数
  # @param danger_threshold [Integer] 危険表示を開始する残り秒数
  # @param on_expire [String] タイマー終了時に呼び出すコールバック名
  # @param size [Symbol] タイマーのサイズ（:compact, :normal, :large）
  # @param show_icon [Boolean] 時計アイコンを表示するかどうか
  def initialize(
    duration_minutes:,
    auto_start: false,
    warning_threshold: nil,
    danger_threshold: nil,
    on_expire: nil,
    size: :normal,
    show_icon: true
  )
    @duration_minutes = duration_minutes
    @duration_seconds = duration_minutes * 60
    @auto_start = auto_start
    @warning_threshold = warning_threshold
    @danger_threshold = danger_threshold
    @on_expire = on_expire
    @size = size
    @show_icon = show_icon
  end

  # 初期表示用のフォーマット済み時間
  # @return [String] "MM:SS"形式の文字列
  def formatted_time
    minutes = @duration_minutes
    seconds = 0
    format("%02d:%02d", minutes, seconds)
  end

  # サイズに応じたCSSクラス
  # @return [String]
  def size_classes
    SIZES[@size] || SIZES[:normal]
  end

  # Stimulusコントローラー用のdata属性（ハイフン形式）
  # @return [Hash]
  def stimulus_data
    data = {
      "controller" => "timer",
      "timer-duration-value" => @duration_seconds,
      "timer-auto-start-value" => @auto_start.to_s
    }

    data["timer-warning-threshold-value"] = @warning_threshold if @warning_threshold
    data["timer-danger-threshold-value"] = @danger_threshold if @danger_threshold
    data["timer-on-expire-value"] = @on_expire if @on_expire

    data
  end

  # アイコンを表示するかどうか
  # @return [Boolean]
  def show_icon?
    @show_icon
  end
end
