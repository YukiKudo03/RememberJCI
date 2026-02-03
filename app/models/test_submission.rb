class TestSubmission < ApplicationRecord
  belongs_to :test
  belongs_to :user

  # 音声ファイルのアタッチメント（FR-52: 音声入力サポート）
  has_one_attached :audio_recording

  enum :status, { pending: 0, auto_graded: 1, manually_graded: 2 }, default: :pending

  validates :test_id, uniqueness: { scope: :user_id }

  # 音声ファイルのバリデーション
  validate :audio_recording_format, if: -> { audio_recording.attached? }

  def final_score
    manual_score.presence || auto_score
  end

  # 音声ファイルがあるかどうか
  def has_audio?
    audio_recording.attached?
  end

  # 音声ファイルのURL（期限付きURL）
  def audio_url(expires_in: 1.hour)
    return nil unless audio_recording.attached?

    if Rails.application.config.active_storage.service == :amazon
      audio_recording.url(expires_in: expires_in)
    else
      Rails.application.routes.url_helpers.rails_blob_path(audio_recording, only_path: true)
    end
  end

  private

  # 許可されるオーディオ形式
  ALLOWED_AUDIO_TYPES = %w[
    audio/webm
    audio/ogg
    audio/mp4
    audio/mpeg
    audio/wav
    audio/x-wav
  ].freeze

  MAX_AUDIO_SIZE = 50.megabytes

  def audio_recording_format
    unless ALLOWED_AUDIO_TYPES.include?(audio_recording.content_type)
      errors.add(:audio_recording, "はサポートされていない形式です")
    end

    if audio_recording.byte_size > MAX_AUDIO_SIZE
      errors.add(:audio_recording, "は50MB以下にしてください")
    end
  end
end
