# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!, unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :verify_authorized, unless: :skip_pundit?
  after_action :verify_policy_scoped, if: :verify_policy_scope_action?

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  private

  def skip_pundit?
    devise_controller?
  end

  def verify_policy_scope_action?
    !skip_pundit? && action_name == "index"
  end

  def user_not_authorized
    flash[:alert] = "この操作を行う権限がありません。"
    redirect_back(fallback_location: root_path)
  end
end
