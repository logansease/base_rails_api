class UsersController < ApplicationController

  include ApplicationHelper
  require 'cgi'

  before_filter :authenticate, :except => [:password_recovery, :send_password_recovery,:send_activation, :activate,:show, :new, :create]
  before_filter :correct_user, :only => [:show,:edit, :update]
  before_filter :admin_user, :only => [:index,:destroy]

  def new
    @tos_page = Page.find_by_title("user_terms")
    @title = "Sign up"
    @user = User.new
  end

  def show
    id = params[:id]
    @user = User.find(id)

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @user, :include => [:following_menu_items, :following_restaurants] }
    end

  end

  def create
    @user = User.new(get_request_as_json params, :user)
    if @user.save
      #redirect_to account_path(@user) OR
      #sign_in @user
      #redirect_to @user, :flash => {:success =>"Welcome to the sample app!"}
      #session['activate_id'] = @user.id
      #redirect_to '/accounts/send_activation'
      #UserMailer.welcome(@user).deliver

      respond_to do |format|
        format.html  {
          sign_in @user
          @user.update_attribute('activated', true)
          redirect_to @user
        }
        format.json  {
          token = Token.generate @user
          render :json => token, :include => :user, :methods => [:access_token, :refresh_token], :except => [:hashed_access_token, :hashed_refresh_token]
        }
      end

    else

      response
      respond_to do |format|
        format.html  {render 'new'}
        format.json  {render :json => respond_with_errors(@user.errors.messages)}
      end
    end
  end

  def edit
    @title = "Edit user"
    #note this assignment isnt needed since it is also called in the pre-filter
    #@user = Account.find(id = params[:id])
  end

  def update

    #previous_email = @user.email
    if @user.update_attributes(get_request_as_json params, :user)

      # if the user changes their email, we should revalidate it.
      #if params[:user][:email] != previous_email
      #  @user.update_attribute("activated", false)
      # send_activation_to @user
      #end

      respond_to do |format|
        format.html  {redirect_to(@user, :flash => {:success =>"Profile Updated."} )}
        format.json  { render :json => @user}
      end

    else
      respond_to do |format|
        format.html  {render 'edit'}
        format.json  { render :json => {:result => "failure", :errors => errors}}
      end

    end
  end

  def index
    @title = "All users"

    @users = User.paginate(:page => params[:page])

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @users}
    end

  end

  def destroy
    User.find(params[:id]).destroy

    respond_to do |format|
      format.html  {redirect_to users_path, :flash => {:success => "User Deleted"}}
      format.json  {render :json => {:result => "failure"}}
    end

  end

  def activate
    if(params[:key])
      dataUrl = params[:key]
      #data = CGI::unescape(dataUrl)
      #data64 = Base64.decode64 data
      data64 = base64_url_decode(dataUrl)
      data_decrypt = decrypt2 data64, CONSTANTS[  :activation_key]
      parsed_json = ActiveSupport::JSON.decode(data_decrypt)
      user_id = parsed_json['user_id']
      key = parsed_json['key']
      user = User.find(user_id)
      if user.activate key
        sign_in user
        redirect_to root_path
      end
    end
  end

  def send_activation
    user = User.find(session['activate_id'])
    send_activation_to user
  end

  def send_password_recovery
    user = User.find_by_email(params['email'])
    if(user)
      key = user.salt
      data = '{ "user_id" : "' + user.id.to_s + '", "key" : "' + key + '" }'
      key_encrypt = encrypt data, CONSTANTS[  :activation_key]
      key_64 = Base64.encode64 key_encrypt
      key64url =  CGI::escape(key_64)
      user.update_attribute(:recover_password, true)
      @url = "http://" + request.host_with_port + "/users/password_recovery?key=#{key64url}"
      UserMailer.password_recovery(user, @url)
      @email = user.email
      message = "Check your email to reset your password"
    else
      message = "Sorry, No user account was found with that email address."
    end

    respond_to do |format|
      format.html  redirect_to root_path, :flash => {:success =>message}
      format.json  { render :json => message}
    end


  end

  def password_recovery
    if(params[:key])
      dataUrl = params[:key]
      #data = CGI::unescape(dataUrl)
      #data64 = Base64.decode64 data
      data64 = base64_url_decode(dataUrl)
      data_decrypt = decrypt2 data64, CONSTANTS[  :activation_key]
      parsed_json = ActiveSupport::JSON.decode(data_decrypt)
      user_id = parsed_json['user_id']
      key = parsed_json['key']
      user = User.find(user_id)
      if key == user.salt && user.recover_password
        sign_in user
        redirect_to edit_user_path(user), :flash => {:success =>"Please reset your password now."}
      else
        redirect_to root_path
      end

    end
  end

  def unlink_provider

    message = "Unlink Failed"

    if(params[:provider_name] and current_user)
      e = ExternalAuthProvider.find_by :provider_type => params[:provider_name], :user_id => current_user.id
      if e and e.delete
        message = "Unlink Successful"
      end
    end

    respond_to do |format|
      format.html  {redirect_to :back, :flash => {:success => message}}
      format.json  { render :json => message}
    end

  end

  private

  def send_activation_to user
    if(!user.activated)
      key = user.salt
      data = '{ "user_id" : "' + user.id.to_s + '", "key" : "' + key + '" }'
      key_encrypt = encrypt data, CONSTANTS[  :activation_key]
      key_64 = Base64.encode64 key_encrypt
      key64url =  CGI::escape(key_64)
      @url = "http://" + request.host_with_port + "/users/activate?key=#{key64url}"
      UserMailer.registration_activation( user, @url).deliver
      @email = user.email
    end
  end

  def correct_user
    @user = User.find(params[:id])

    if !current_user? @user
      deny_access
    end
  end

end