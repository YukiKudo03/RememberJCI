# frozen_string_literal: true

# FlashComponent - フラッシュメッセージコンポーネント
#
# フラッシュメッセージを表示するコンポーネント。
# notice, alert, error, info の4タイプに対応。
# 自動非表示と手動閉じるボタンをサポート。
#
# @example 基本的な使用
#   <%= render FlashComponent.new(type: :notice, message: "保存しました") %>
#
# @example オプション付き
#   <%= render FlashComponent.new(
#     type: :error,
#     message: "エラーが発生しました",
#     auto_dismiss_ms: 10000,
#     dismissible: true
#   ) %>
#
class FlashComponent < ApplicationComponent
  STYLES = {
    notice: {
      css_class: "flash-notice",
      bg: "bg-green-100 border-green-400",
      text: "text-green-700",
      icon: "text-green-500",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
    },
    success: {
      css_class: "flash-notice",
      bg: "bg-green-100 border-green-400",
      text: "text-green-700",
      icon: "text-green-500",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z"
    },
    alert: {
      css_class: "flash-alert",
      bg: "bg-yellow-100 border-yellow-400",
      text: "text-yellow-700",
      icon: "text-yellow-500",
      icon_path: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
    },
    warning: {
      css_class: "flash-alert",
      bg: "bg-yellow-100 border-yellow-400",
      text: "text-yellow-700",
      icon: "text-yellow-500",
      icon_path: "M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z"
    },
    error: {
      css_class: "flash-error",
      bg: "bg-red-100 border-red-400",
      text: "text-red-700",
      icon: "text-red-500",
      icon_path: "M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"
    },
    info: {
      css_class: "flash-info",
      bg: "bg-blue-100 border-blue-400",
      text: "text-blue-700",
      icon: "text-blue-500",
      icon_path: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
    }
  }.freeze

  DEFAULT_AUTO_DISMISS_MS = 5000

  # @param type [Symbol, String] メッセージタイプ（:notice, :alert, :error, :info）
  # @param message [String, nil] メッセージ内容
  # @param dismissible [Boolean] 閉じるボタンを表示するかどうか
  # @param auto_dismiss_ms [Integer] 自動非表示までのミリ秒（0で無効）
  def initialize(type:, message:, dismissible: true, auto_dismiss_ms: DEFAULT_AUTO_DISMISS_MS)
    @type = type.to_sym
    @message = message
    @dismissible = dismissible
    @auto_dismiss_ms = auto_dismiss_ms
  end

  # メッセージが空の場合はレンダリングしない
  # @return [Boolean]
  def render?
    @message.present?
  end

  # メッセージ内容
  # @return [String]
  attr_reader :message

  # 閉じるボタンを表示するかどうか
  # @return [Boolean]
  def dismissible?
    @dismissible
  end

  # スタイル情報
  # @return [Hash]
  def style
    STYLES[@type] || STYLES[:info]
  end

  # CSS クラス名
  # @return [String]
  def css_class
    style[:css_class]
  end

  # 背景色クラス
  # @return [String]
  def bg_classes
    style[:bg]
  end

  # テキスト色クラス
  # @return [String]
  def text_classes
    style[:text]
  end

  # アイコン色クラス
  # @return [String]
  def icon_classes
    style[:icon]
  end

  # アイコンパス
  # @return [String]
  def icon_path
    style[:icon_path]
  end

  # Stimulusデータ属性
  # @return [Hash]
  def stimulus_data
    {
      "controller" => "flash",
      "flash-auto-dismiss-value" => @auto_dismiss_ms
    }
  end
end
