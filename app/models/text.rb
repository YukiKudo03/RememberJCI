class Text < ApplicationRecord
  has_paper_trail

  # =============================================================================
  # Enums
  # =============================================================================
  enum :difficulty, { easy: 0, medium: 1, hard: 2 }, default: :medium

  # =============================================================================
  # Associations
  # =============================================================================
  belongs_to :created_by, class_name: "User"
  has_many :assignments, dependent: :destroy
  has_many :learning_progresses, dependent: :destroy
  has_many :tests, dependent: :destroy

  # =============================================================================
  # Validations
  # =============================================================================
  validates :title, presence: true
  validates :content, presence: true

  # =============================================================================
  # Instance Methods
  # =============================================================================

  # Returns the word count of the content
  # @return [Integer] The number of words in the content
  def word_count
    content.split.count
  end
end
