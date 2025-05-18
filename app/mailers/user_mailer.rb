# app/mailers/user_mailer.rb
class UserMailer < ApplicationMailer
  # 既存アカウント紐付け用
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

  # LINEログイン直後の「メール同時登録」用
  def line_link_account_email(user, email)
    @user  = user
    @email = email
    token  = user.link_token

    @link_url = Rails.application.routes.url_helpers.
      line_link_account_users_url(token: token, email: email,
        host: default_url_options[:host], port: default_url_options[:port])

    mail(to: email, subject: "アカウント結びつけの確認")
  end
end
