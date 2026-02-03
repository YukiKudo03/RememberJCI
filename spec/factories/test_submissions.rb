# spec/factories/test_submissions.rb
FactoryBot.define do
  factory :test_submission do
    association :test
    association :user
    submitted_text { "提出されたテキスト" }
    auto_score { nil }
    manual_score { nil }
    status { :pending }

    trait :auto_graded do
      status { :auto_graded }
      auto_score { 85 }
    end

    trait :manually_graded do
      status { :manually_graded }
      manual_score { 90 }
    end
  end
end
