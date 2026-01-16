class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized


  protect_from_forgery with: :exception
  #before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_filter :get_git_branch

  def get_git_branch
    @git_branch = `git rev-parse --abbrev-ref HEAD` + " " + `git rev-parse --short HEAD`
  end

  def after_sign_in_path_for(resource)
    user_path(current_user)
  end

  def query_params
    query = params[:q] || {}
    Hash[query.map { |key, value| [key, value.strip] }]
  end
  

  before_action :prepare_exception_notifier

  private

  def prepare_exception_notifier
    request.env["exception_notifier.exception_data"] = {
      current_user: current_user
    }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:givenName, :familyName, :avatar, :group_name, :desired_group_name,  :affiliation, :affiliationIdentifier, :url, :nameIdentifier, :assignments, :groups, :desired_role, assignments_attributes:[:_destroy, :id, :group_id, :group_name, :user_id, :group, :role]])
    devise_parameter_sanitizer.permit(:account_update, keys: [:givenName, :familyName, :avatar, :group_name, :desired_group_name, :affiliation, :affiliationIdentifier, :url, :nameIdentifier, :desired_role, :assignments, assignments_attributes:[:_destroy, :id, :group_id, :group_name, :user_id, :group, :role]])
  end


  # before_filter :update_sanitized_params, if: :devise_controller?
  #
  # def update_sanitized_params
  #   devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:bio, :name)}
  # end

  private

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
