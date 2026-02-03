# app/services/learning/practice_service.rb
module Learning
  class PracticeService
    BLANK_PERCENTAGES = {
      0 => 0.0,
      1 => 0.2,
      2 => 0.4,
      3 => 0.6,
      4 => 0.8,
      5 => 1.0
    }.freeze

    attr_reader :user, :text

    def initialize(user:, text:)
      @user = user
      @text = text
    end

    def progress
      @progress ||= LearningProgress.find_or_create_by(user: user, text: text)
    end

    def content_with_blanks(level:)
      return text.content if level == 0

      percentage = BLANK_PERCENTAGES[level] || 1.0
      words = text.content.split
      blank_count = (words.count * percentage).round

      # Create consistent blank positions based on text content
      indices_to_blank = (0...words.count).to_a.sample(blank_count, random: Random.new(text.id))

      words.each_with_index.map do |word, index|
        if indices_to_blank.include?(index)
          "_" * word.length
        else
          word
        end
      end.join(" ")
    end

    def save_attempt(level:, time_spent:, score:)
      progress.update!(
        current_level: level,
        total_study_time: progress.total_study_time + time_spent,
        best_score: [progress.best_score, score].max,
        total_attempts: progress.total_attempts + 1
      )
    end
  end
end
