# frozen_string_literal: true

module Learning
  # ProgressIndicatorComponent - 学習進捗インジケーターコンポーネント
  #
  # 進捗バーを表示するコンポーネント。
  # サイズ、色、ラベル、アニメーションをカスタマイズ可能。
  #
  # @example 基本的な使用
  #   <%= render Learning::ProgressIndicatorComponent.new(current: 50, total: 100) %>
  #
  # @example オプション付き
  #   <%= render Learning::ProgressIndicatorComponent.new(
  #     current: 75,
  #     total: 100,
  #     label: "75 / 100 完了",
  #     size: :thick,
  #     color: :green
  #   ) %>
  #
  class ProgressIndicatorComponent < ApplicationComponent
    SIZES = {
      thin: { bar_height: "h-1", css_class: "progress-thin" },
      normal: { bar_height: "h-2.5", css_class: "progress-normal" },
      thick: { bar_height: "h-4", css_class: "progress-thick" }
    }.freeze

    COLORS = {
      indigo: "bg-indigo-600",
      green: "bg-green-600",
      blue: "bg-blue-600",
      red: "bg-red-600",
      yellow: "bg-yellow-500",
      purple: "bg-purple-600"
    }.freeze

    # @param current [Integer] 現在の進捗値
    # @param total [Integer] 全体の値
    # @param label [String, nil] カスタムラベル（nilの場合はパーセント表示）
    # @param show_label [Boolean] ラベルを表示するかどうか
    # @param size [Symbol] バーのサイズ（:thin, :normal, :thick）
    # @param color [Symbol] バーの色（:indigo, :green, :blue, :red, :yellow, :purple）
    # @param animated [Boolean] アニメーションを有効にするかどうか
    def initialize(
      current:,
      total:,
      label: nil,
      show_label: true,
      size: :normal,
      color: :indigo,
      animated: true
    )
      @current = current
      @total = total
      @label = label
      @show_label = show_label
      @size = size
      @color = color
      @animated = animated
    end

    # 進捗率（パーセント）
    # @return [Integer]
    def percentage
      return 0 if @total.zero?

      ((@current.to_f / @total) * 100).round
    end

    # ラベルテキスト
    # @return [String]
    def label_text
      @label || "#{percentage}%"
    end

    # ラベルを表示するかどうか
    # @return [Boolean]
    def show_label?
      @show_label
    end

    # 完了しているかどうか
    # @return [Boolean]
    def complete?
      percentage >= 100
    end

    # バーの高さクラス
    # @return [String]
    def bar_height
      size_config[:bar_height]
    end

    # サイズのCSSクラス
    # @return [String]
    def size_class
      size_config[:css_class]
    end

    # バーの色クラス
    # @return [String]
    def color_class
      COLORS[@color] || COLORS[:indigo]
    end

    # アニメーションのCSSクラス
    # @return [String]
    def animation_classes
      @animated ? "transition-all duration-500 ease-out" : ""
    end

    # コンテナのCSSクラス
    # @return [String]
    def container_classes
      classes = [ "progress-indicator", size_class ]
      classes << "progress-complete" if complete?
      classes.join(" ")
    end

    private

    def size_config
      SIZES[@size] || SIZES[:normal]
    end
  end
end
