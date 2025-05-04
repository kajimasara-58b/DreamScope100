# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  def link_account_email(user, email)
    @user = user
    @email = email
    @link_url = Rails.application.routes.url_helpers.link_account_users_url(
      token: user.link_token,
      email: email,
      host: Rails.configuration.action_mailer.default_url_options[:host],
      port: Rails.configuration.action_mailer.default_url_options[:port]
    )
    mail(to: email, subject: "アカウント結びつけの確認")
  end
end
