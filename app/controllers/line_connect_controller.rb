class LineConnectController < ApplicationController
  before_action :authenticate_user! # ログイン必須

  def connect
    user = current_user
    user.update(line_notice_id: params[:user_id])
    redirect_to root_path, notice: "LINE通知を有効にしました"
  end
end
