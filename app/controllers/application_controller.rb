class ApplicationController < ActionController::Base
   # protect_from_forgery :except => [:fb_signin, :create_fb]

  rescue_from Exception, :with => :application_error

  before_filter :login_with_access_token
  before_filter :check_for_json_content_type

  #helper is only available in views, so include the helper in controller
  #by putting here, get it in all controllers
  include SessionsHelper
  include ApplicationHelper

  def admin_user
    if (!current_user or !current_user.admin?)
      deny_access
    end
  end


  def application_error exception
    respond_to do |format|
      format.json {
        response.status = 500
        render :json => {:error => exception.message}
        puts exception
        puts exception.backtrace
      }
      format.html{
        puts exception
        puts exception.backtrace
        redirect_to request.env['HTTP_REFERER'] || root_path, :flash => {:error => "ERROR\n" + exception.message}
      }
      format.all
    end
    true
  end

end
