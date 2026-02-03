# frozen_string_literal: true

# app/services/testing/scoring_service.rb
module Testing
  # ScoringService provides automatic grading for typing-based tests
  # by comparing submitted text against the original text content.
  #
  # Requirements: FR-51 (差分比較によるタイピングテストの自動採点)
  #
  # @example Calculate score for a submission
  #   service = Testing::ScoringService.new(submission: submission)
  #   score = service.calculate_score
  #
  # @example Grade and save the score
  #   service = Testing::ScoringService.new(submission: submission)
  #   service.grade!
  #
  class ScoringService
    attr_reader :submission

    # @param submission [TestSubmission] The test submission to grade
    def initialize(submission:)
      @submission = submission
    end

    # Calculates the score based on word-by-word comparison
    # @return [Float] Score from 0.0 to 100.0
    def calculate_score
      return 0.0 if submitted_text.blank?

      correct_count = 0
      submitted_words = normalize_text(submitted_text).split
      original_words = normalize_text(original_text).split

      return 0.0 if original_words.empty?

      # Compare word by word
      original_words.each_with_index do |word, index|
        if submitted_words[index] == word
          correct_count += 1
        end
      end

      # Calculate percentage
      (correct_count.to_f / original_words.count * 100).round(1)
    end

    # Returns diff information between original and submitted text
    # @return [Array<Hash>] Array of diff segments with type and text
    def diff
      submitted_words = normalize_text(submitted_text).split
      original_words = normalize_text(original_text).split

      result = []
      max_length = [submitted_words.length, original_words.length].max

      max_length.times do |i|
        original_word = original_words[i]
        submitted_word = submitted_words[i]

        if original_word == submitted_word
          result << { type: :equal, text: original_word }
        elsif original_word.nil?
          # Extra word in submission
          result << { type: :insert, text: submitted_word }
        elsif submitted_word.nil?
          # Missing word in submission
          result << { type: :delete, text: original_word }
        else
          # Different word
          result << { type: :delete, text: original_word }
          result << { type: :insert, text: submitted_word }
        end
      end

      result
    end

    # Calculates score and updates the submission record
    # @return [Float] The calculated score
    def grade!
      score = calculate_score
      submission.update!(
        auto_score: score.to_i,
        status: :auto_graded
      )
      GradingMailer.graded(submission).deliver_later
      score
    end

    private

    # @return [String] The submitted text content
    def submitted_text
      @submission.submitted_text || ""
    end

    # @return [String] The original text content from the test's text
    def original_text
      @submission.test.text.content || ""
    end

    # Normalizes text for comparison by removing extra whitespace
    # @param text [String] Text to normalize
    # @return [String] Normalized text
    def normalize_text(text)
      text.to_s.gsub(/\s+/, " ").strip
    end
  end
end
