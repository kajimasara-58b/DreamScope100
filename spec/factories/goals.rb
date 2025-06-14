FactoryBot.define do
  factory :goal do
    user
    title { Faker::Lorem.sentence(word_count: 3) }
    status { '未' }
    due_date { 1.week.from_now }
    category { '健康' }
    notify_enabled { false }
    notify_days_before { nil }
  end
end