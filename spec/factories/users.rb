# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    password_confirmation { "password123" }
    role { :learner }
    confirmed_at { Time.current }

    trait :admin do
      role { :admin }
    end

    trait :teacher do
      role { :teacher }
    end

    trait :learner do
      role { :learner }
    end
  end
end
