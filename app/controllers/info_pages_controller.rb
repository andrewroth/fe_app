class InfoPagesController < ApplicationController
  before_filter :set_title
  layout 'fe/application'

  def index
    if user_signed_in?
      redirect_to show_default_path
    else
      redirect_to :action => :home
    end
  end

  def home
    @active = "home"
  end

  def instructions
    @active = "instructions"
  end

  protected

  def set_title
    @title = "Form Engine"
  end
end
