# spec/factories/texts.rb
FactoryBot.define do
  factory :text do
    sequence(:title) { |n| "テキスト#{n}" }
    content { "これは暗記用のテキストです。しっかり覚えましょう。" }
    category { "一般" }
    difficulty { :medium }
    association :created_by, factory: :user

    trait :easy do
      difficulty { :easy }
    end

    trait :hard do
      difficulty { :hard }
    end
  end
end
