# lib/tasks/fix_tweets.rake
namespace :fix do
  desc "Set default user_id to tweets"
  task add_default_user_to_tweets: :environment do
    default_user = User.find_by(email: "default@example.com")
    raise "Default user not found" unless default_user

    Tweet.where(user_id: nil).update_all(user_id: default_user.id)
    puts "Tweets updated with default user"
  end
end
