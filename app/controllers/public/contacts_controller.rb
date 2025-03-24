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
      end
    elsif request.get?
      if session[:contact_params].present?
        @contact = Contact.new(session[:contact_params])
      else
        redirect_to new_public_contact_path, alert: "確認データがありません。入力からやり直してください。"
        return
      end
    end
  end

  def back
    @contact = Contact.new(contact_params)
    render :new
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.send_mail(@contact).deliver_now
      redirect_to done_public_contacts_path
    else
      flash[:alert] = @contact.errors.full_messages.join(", ")
      render :new
    end
  end

  def done
  end

    private

    def contact_params
      params.require(:contact).permit(:name, :email, :subject, :message)
    end
end