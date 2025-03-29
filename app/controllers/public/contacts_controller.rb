class Public::ContactsController < ApplicationController
  def new
    @contact = Contact.new
  end

  def confirm
    if request.post?
      @contact = Contact.new(contact_params)
      if @contact.invalid?
        flash[:alert] = @contact.errors.full_messages.join(", ")
        render :new
      else
        session[:contact_params] = contact_params
        session[:contact_submitted] = false # 送信済みフラグを初期化
      end
    elsif request.get?
      if session[:contact_submitted]
        redirect_to root_path, notice: "お問い合わせはすでに送信済みです。"
      end
      if session[:contact_params].present?
        @contact = Contact.new(session[:contact_params])
      else
        redirect_to new_public_contact_path, alert: "確認データがありません。入力からやり直してください。"
      end
    end
  end

  def back
    @contact = Contact.new(contact_params)
    render :new
  end

  def create
    if session[:contact_params].present? && session[:contact_params]["name"].present?
      @contact = Contact.new(session[:contact_params])
      if @contact.save
        ContactMailer.send_mail(@contact).deliver_now
        session[:contact_submitted] = true # 送信済みフラグを設定
        redirect_to done_public_contacts_path
      else
        flash[:alert] = @contact.errors.full_messages.join(", ")
        render :new
      end
    else
      redirect_to new_public_contact_path, alert: "送信データがありません。入力からやり直してください。"
    end
  end

  def done
    session[:contact_params] = nil
    session[:contact_submitted] = nil # セッションをクリア
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
