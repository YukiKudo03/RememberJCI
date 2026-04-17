# frozen_string_literal: true

FactoryBot.define do
  factory :group_invite do
    association :group
    association :created_by, factory: :user
    expires_at { 7.days.from_now }
    max_uses { 10 }
    uses_count { 0 }
    revoked_at { nil }

    trait :expired do
      expires_at { 1.day.ago }
    end

    trait :revoked do
      revoked_at { 1.hour.ago }
    end

    trait :exhausted do
      max_uses { 1 }
      uses_count { 1 }
    end
  end
end
