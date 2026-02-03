# frozen_string_literal: true

module Learning
  class TextsController < ApplicationController
    skip_after_action :verify_authorized
    skip_after_action :verify_policy_scoped

    before_action :set_text, only: [:show, :practice, :save_progress, :self_test, :check_self_test]
    before_action :authorize_text, only: [:show, :practice, :save_progress, :self_test, :check_self_test]

    rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

    def index
      # Get texts assigned to the current user (directly or via groups)
      direct_assignments = Assignment.where(user: current_user)
      group_assignments = Assignment.where(group: current_user.groups)

      @assignments = (direct_assignments + group_assignments).uniq(&:text_id)
      text_ids = @assignments.map(&:text_id)
      @texts = Text.where(id: text_ids)

      # Get learning progress for each text
      @progresses = LearningProgress.where(user: current_user, text_id: text_ids)
                                    .index_by(&:text_id)
    end

    def show
      @practice_service = PracticeService.new(user: current_user, text: @text)
    end

    def practice
      @practice_service = PracticeService.new(user: current_user, text: @text)
      @level = params[:level].to_i
      @content = @practice_service.content_with_blanks(level: @level)
    end

    def self_test
    end

    def check_self_test
      @submitted_text = params[:submitted_text].to_s
      @score = calculate_self_test_score(@text.content, @submitted_text)
      @diff = calculate_diff(@text.content, @submitted_text)

      # Save progress
      practice_service = Learning::PracticeService.new(user: current_user, text: @text)
      practice_service.save_attempt(
        level: 5,
        time_spent: 0,
        score: @score.to_i
      )

      render :self_test_result
    end

    def save_progress
      practice_service = PracticeService.new(user: current_user, text: @text)
      practice_service.save_attempt(
        level: params[:level].to_i,
        time_spent: params[:time_spent].to_i,
        score: params[:score].to_i
      )

      render json: {
        success: true,
        progress: practice_service.progress.as_json(only: [:current_level, :best_score, :total_study_time])
      }
    end

    private

    def set_text
      @text = Text.find(params[:id])
    end

    def authorize_text
      # Check if user has access to this text (via direct or group assignment)
      direct = Assignment.exists?(user: current_user, text: @text)
      via_group = Assignment.exists?(group: current_user.groups, text: @text)

      raise Pundit::NotAuthorizedError unless direct || via_group
    end

    def render_forbidden
      render plain: "Forbidden", status: :forbidden
    end

    def normalize_text(text)
      text.to_s.gsub(/\s+/, " ").strip
    end

    def calculate_self_test_score(original, submitted)
      original_words = normalize_text(original).split
      submitted_words = normalize_text(submitted).split

      return 0.0 if original_words.empty?

      correct_count = original_words.each_with_index.count do |word, index|
        submitted_words[index] == word
      end

      (correct_count.to_f / original_words.count * 100).round(1)
    end

    def calculate_diff(original, submitted)
      original_words = normalize_text(original).split
      submitted_words = normalize_text(submitted).split

      max_length = [original_words.length, submitted_words.length].max
      result = []

      max_length.times do |i|
        original_word = original_words[i]
        submitted_word = submitted_words[i]

        if original_word == submitted_word
          result << { type: :equal, text: original_word }
        elsif original_word.nil?
          result << { type: :insert, text: submitted_word }
        elsif submitted_word.nil?
          result << { type: :delete, text: original_word }
        else
          result << { type: :delete, text: original_word }
          result << { type: :insert, text: submitted_word }
        end
      end

      result
    end
  end
end
