class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :require_login

  def logged_in?() session[:person_id].present?  end
  def logged_in() logged_in?; end # form engine expects this
  def user_signed_in?() logged_in?; end # form engine expects this
  helper_method :logged_in?, :logged_in, :user_signed_in?

  def current_person
    return unless logged_in?
    begin
      return @current_person if @current_person
      if session[:impersonate_person_id]
        person ||= Fe::Person.find(session[:impersonate_person_id])
        @current_person = @person ||= person
        person
      else
        person ||= Fe::Person.find(session[:person_id])
        @current_person = @person ||= person
        person
      end
    rescue
      person_id = session[:person_id]
      reset_session
      throw "Invalid session person_id of #{person_id}."
    end
  end
  helper_method :current_person

  protected

  def require_login
    redirect_to new_session_path unless logged_in?
  end

  def check_valid_user
    true
  end
end
