module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      Rails.logger.info "ActionCable connected for user: #{current_user&.id}"
    end

    private

    def find_verified_user
      user_id = cookies.signed[:user_id]
      Rails.logger.info "ActionCable: Looking for user with ID #{user_id}"
      if verified_user = User.find_by(id: user_id)
        verified_user
      else
        Rails.logger.warn "ActionCable: User not found for ID #{user_id}, rejecting connection"
        reject_unauthorized_connection
      end
    end
  end
end