# frozen_string_literal: true

module Learning
  # TextDisplayComponent renders text content with blanks for memorization practice.
  # Supports different levels of blank coverage and interactive mode for learning.
  #
  # @example Basic usage
  #   <%= render Learning::TextDisplayComponent.new(
  #     text_content: "これは ____ 文章です",
  #     original_text: "これは テスト 文章です",
  #     level: 2
  #   ) %>
  #
  # @example Interactive mode
  #   <%= render Learning::TextDisplayComponent.new(
  #     text_content: blanked_content,
  #     original_text: original,
  #     level: 3,
  #     interactive: true
  #   ) %>
  #
  class TextDisplayComponent < ApplicationComponent
    BLANK_PATTERN = /_{2,}/.freeze

    # @param text_content [String] The text content with blanks (underscores)
    # @param original_text [String] The original text without blanks
    # @param level [Integer] The current practice level (0-5)
    # @param show_answers [Boolean] Whether to reveal answers instead of blanks
    # @param interactive [Boolean] Whether blanks are clickable
    def initialize(text_content:, original_text:, level:, show_answers: false, interactive: false)
      @text_content = text_content
      @original_text = original_text
      @level = level
      @show_answers = show_answers
      @interactive = interactive
    end

    # @return [Boolean] true if there are any blanks in the content
    def has_blanks?
      @text_content.match?(BLANK_PATTERN)
    end

    # @return [Array<Hash>] Array of word segments with type info
    def parsed_content
      return [{ type: :text, value: @text_content }] unless has_blanks?

      original_words = @original_text.split
      content_words = @text_content.split
      word_index = 0

      content_words.map do |word|
        if word.match?(BLANK_PATTERN)
          original_word = original_words[word_index]
          word_index += 1
          {
            type: :blank,
            value: word,
            answer: original_word,
            index: word_index - 1
          }
        else
          word_index += 1
          { type: :text, value: word }
        end
      end
    end

    # @return [String] CSS classes for the container
    def container_classes
      "prose max-w-none text-lg leading-relaxed"
    end

    # @return [Hash] Data attributes for the container
    def container_data
      data = {
        level: @level
      }

      if @interactive
        data[:controller] = "text-display"
        data[:text_display_level_value] = @level
      end

      data
    end

    # @return [String] CSS classes for blank elements
    def blank_classes
      base = "blank inline-block px-2 py-0.5 mx-0.5 rounded border-b-2 border-dashed border-gray-400 bg-gray-100"
      base += " cursor-pointer hover:bg-gray-200" if @interactive
      base
    end

    # @return [Hash] Data attributes for blank elements
    def blank_data(index)
      return {} unless @interactive

      {
        action: "click->text-display#revealBlank",
        text_display_target: "blank",
        index: index
      }
    end
  end
end
