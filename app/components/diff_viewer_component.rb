# frozen_string_literal: true

# DiffViewerComponent - テスト結果の差分表示コンポーネント
#
# 要件参照: US-L03（自己テスト - 差分ハイライトでエラー表示）
#
# @example 基本的な使用
#   <%= render DiffViewerComponent.new(diff: diff_array) %>
#
# @example オプション付き
#   <%= render DiffViewerComponent.new(
#     diff: diff_array,
#     mode: :inline,
#     show_legend: true,
#     show_success_message: true,
#     show_score: true
#   ) %>
#
class DiffViewerComponent < ApplicationComponent
  MODES = {
    inline: "diff-inline",
    side_by_side: "diff-side-by-side"
  }.freeze

  DIFF_STYLES = {
    equal: {
      class: "diff-equal text-gray-900",
      aria_label: "一致"
    },
    delete: {
      class: "diff-delete bg-red-100 text-red-800 line-through px-1 rounded",
      aria_label: "欠落している単語"
    },
    insert: {
      class: "diff-insert bg-green-100 text-green-800 underline px-1 rounded",
      aria_label: "余分な単語"
    }
  }.freeze

  # @param diff [Array<Hash>] 差分配列（{ type: :equal/:delete/:insert, text: "word" }）
  # @param mode [Symbol] 表示モード（:inline, :side_by_side）
  # @param show_legend [Boolean] 凡例を表示するか
  # @param show_success_message [Boolean] 完全一致時にメッセージを表示するか
  # @param show_score [Boolean] スコアを表示するか
  def initialize(
    diff:,
    mode: :inline,
    show_legend: false,
    show_success_message: false,
    show_score: false
  )
    @diff = diff || []
    @mode = mode
    @show_legend = show_legend
    @show_success_message = show_success_message
    @show_score = show_score
  end

  # 差分配列を取得
  # @return [Array<Hash>]
  def diff_items
    @diff
  end

  # 表示モードに応じたCSSクラス
  # @return [String]
  def mode_class
    MODES[@mode] || MODES[:inline]
  end

  # 差分タイプに応じたスタイル情報を取得
  # @param type [Symbol] 差分タイプ（:equal, :delete, :insert）
  # @return [Hash]
  def style_for(type)
    DIFF_STYLES[type] || DIFF_STYLES[:equal]
  end

  # 凡例を表示するか
  # @return [Boolean]
  def show_legend?
    @show_legend
  end

  # 成功メッセージを表示するか（完全一致時のみ）
  # @return [Boolean]
  def show_success_message?
    @show_success_message && perfect_match?
  end

  # スコアを表示するか
  # @return [Boolean]
  def show_score?
    @show_score
  end

  # 完全一致かどうか
  # @return [Boolean]
  def perfect_match?
    @diff.present? && @diff.all? { |item| item[:type] == :equal }
  end

  # スコアを計算（正解単語数 / 期待単語数 * 100）
  # @return [Integer]
  def calculated_score
    return 100 if @diff.empty?

    equal_count = @diff.count { |item| item[:type] == :equal }
    # deleteは期待されたが提出されなかった単語
    expected_count = @diff.count { |item| item[:type] == :equal || item[:type] == :delete }

    return 0 if expected_count == 0

    ((equal_count.to_f / expected_count) * 100).round
  end
end
