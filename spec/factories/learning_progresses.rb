# spec/factories/learning_progresses.rb
FactoryBot.define do
  factory :learning_progress do
    association :user
    association :text
    current_level { 0 }
    best_score { 0 }
    total_attempts { 0 }
    total_study_time { 0 }
  end
end
