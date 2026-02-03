# spec/factories/tests.rb
FactoryBot.define do
  factory :test do
    sequence(:title) { |n| "テスト#{n}" }
    test_type { :typing }
    time_limit { 30 }
    association :text
    association :created_by, factory: :user
    available_from { nil }
    available_until { nil }

    trait :typing do
      test_type { :typing }
    end

    trait :audio do
      test_type { :audio }
    end

    trait :with_time_limit do
      time_limit { 60 }
    end

    trait :available_now do
      available_from { 1.day.ago }
      available_until { 1.day.from_now }
    end
  end
end
