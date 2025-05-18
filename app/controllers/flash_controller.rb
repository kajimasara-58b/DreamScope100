class FlashController < ApplicationController
  def create
    flash.now[:alert] = params[:alert] if params[:alert]
    render partial: "shared/flash"
  rescue StandardError => e
    Rails.logger.error "Flash rendering error: #{e.message}"
    render plain: "Error rendering flash: #{e.message}", status: :internal_server_error
  end
end
