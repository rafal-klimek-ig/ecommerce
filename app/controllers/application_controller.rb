class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  protect_from_forgery with: :exception

  # Make current_order available in all controllers and views
  helper_method :current_order

  private

  def current_order
    return nil unless user_signed_in?

    @current_order ||= current_user.orders.find_by(status: 'pending')
  end
end
