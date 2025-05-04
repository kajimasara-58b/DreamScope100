# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :authenticate_user!, except: [ :email, :update_email, :skip_email_registration ]
  skip_before_action :require_no_authentication, only: [ :email, :update_email, :skip_email_registration ]

  def email
    @user = User.new(name: session[:line_auth]&.dig("name"))
  end

  def update_email
    @user = User.new(user_params.merge(
      uid: session[:line_auth]["uid"],
      provider: "line",
      name: session[:line_auth]["name"] || "LINEユーザー",
      active: true
    ))
    if @user.save
      sign_in(@user)
      session.delete(:line_auth)
      redirect_to dashboard_index_path, notice: "メールアドレスを登録しました！"
    else
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :email, status: :unprocessable_entity
    end
  end

  def skip_email_registration
    Rails.logger.debug "skip_email_registration called with params: #{params.inspect}, session: #{session.inspect}"
    unless session[:line_auth]
      redirect_to new_user_session_path, alert: "LINEログイン情報がありません。もう一度ログインしてください。"
      return
    end

    @user = User.new(
      uid: session[:line_auth]["uid"],
      provider: "line",
      name: session[:line_auth]["name"] || "LINEユーザー",
      email: nil,
      password: nil,
      active: true,
      is_dummy_password: true # LINEログインではパスワード未設定
    )
    if @user.save
      sign_in(@user)
      session.delete(:line_auth)
      redirect_to dashboard_index_path, notice: "LINE認証でログインしました。アプリ内でメールアドレスとパスワードを設定できます"
    else
      Rails.logger.debug "User save failed: #{@user.errors.full_messages}"
      flash.now[:alert] = @user.errors.full_messages.join(", ")
      render :email, status: :unprocessable_entity
    end
  end

  def create
    super do |resource|
      if resource.persisted?
        sign_out(resource)
        redirect_to new_user_session_path, notice: "登録が完了しました。ログインしてください。" and return
      end
    end
  end

  def edit
    super
  end

  def send_password_reset
    @user = User.active.find_by(name: params[:user][:name], email: params[:user][:email])
    if @user && @user.valid_password?(params[:user][:current_password])
      @user.send_reset_password_instructions
      redirect_to registration_done_path
    else
      flash[:alert] = "ユーザー名またはメールアドレス、現在のパスワードが正しくありません。"
      render :edit, status: :unprocessable_entity
    end
  end

  def done
  end

  protected

  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :email, :uid, :provider ])
  end
end