class Test < ApplicationRecord
  # Enums
  enum :test_type, { typing: 0, audio: 1 }

  # Associations
  belongs_to :text
  belongs_to :created_by, class_name: "User"
  has_many :submissions, class_name: "TestSubmission", dependent: :destroy

  # Validations
  validates :test_type, presence: true

  # Returns true if current time is within available_from and available_until
  # Returns true if the time constraints are nil (no restriction)
  def available?
    now = Time.current
    from_ok = available_from.nil? || now >= available_from
    until_ok = available_until.nil? || now <= available_until
    from_ok && until_ok
  end
end
