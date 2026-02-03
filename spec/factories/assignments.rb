# spec/factories/assignments.rb
FactoryBot.define do
  factory :assignment do
    association :text
    association :assigned_by, factory: :user
    deadline { 1.week.from_now }

    trait :to_user do
      association :user
      group { nil }
    end

    trait :to_group do
      user { nil }
      association :group
    end

    trait :overdue do
      deadline { 1.day.ago }
    end
  end
end
