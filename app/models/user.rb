class User < ApplicationRecord
  # =============================================================================
  # Constants
  # =============================================================================
  ROLES = { learner: 0, teacher: 1, admin: 2 }.freeze

  # =============================================================================
  # Devise Configuration
  # =============================================================================
  # Available modules: :confirmable, :lockable, :timeoutable, :trackable, :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :timeoutable, :confirmable

  # =============================================================================
  # Enums
  # =============================================================================
  enum :role, ROLES, default: :learner

  # =============================================================================
  # Associations
  # =============================================================================
  has_many :group_memberships, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :learning_progresses, dependent: :destroy
  has_many :test_submissions, dependent: :destroy
  has_many :achievements, dependent: :destroy

  # =============================================================================
  # Validations
  # =============================================================================
  validates :name, presence: true

  # =============================================================================
  # Scopes
  # =============================================================================
  scope :admins, -> { where(role: :admin) }
  scope :teachers, -> { where(role: :teacher) }
  scope :learners, -> { where(role: :learner) }

  # =============================================================================
  # Instance Methods
  # =============================================================================

  # Returns a human-readable role name for display purposes
  # @return [String] The titleized role name
  def display_role
    role.titleize
  end
end
