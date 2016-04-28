class TokensController < ApplicationController

  include ExternalAuthHelper

  def create
    user = User.authenticate params[:username],params[:password]
    printf params.inspect
    if(user)
      Token.where(:user => user).delete_all
      token = Token.generate (user)
    else
      response.status = 403
      render :json => {:errors => "Invalid login"}
      return
    end

    if token.save
      render json: token, :include => :user, :methods => [:access_token, :refresh_token], :except => [:hashed_access_token, :hashed_refresh_token]
    else
      render :json => {:errors => "invalid login"}
    end
  end

  def refresh
    token = Token.refresh(params[:refresh_token])
    if token.save
      render json: token, :methods => [:access_token, :refresh_token], :except => [:hashed_access_token, :hashed_refresh_token]
    else
      render :json => {:errors => "refresh token invalid"}
    end
  end

  def fb_canvas
    signed = params[:signed_request]
    fb_secret = CONSTANTS[  :fb_secret]

    request_data = parse_signed_request fb_secret, signed

    access_token = request_data["oauth_token"]
    #fb_id = request_data[:user_id]

    session[:canvas] = true

    temp_token = Token.new
    temp_token.access_token= access_token
    temp_token.provider = PROVIDER_FACEBOOK

    if current_user
      temp_user = current_user
    else
      temp_user = User.from_external_token temp_token.access_token, temp_token.provider
    end

    begin
      token = do_external_auth temp_user, temp_token
      sign_in token.user
    rescue => error
    end
    #set up the page
    @full_width = true
    @include_itunes_meta = true

    #render
    render 'pages/home'
  end

  def web_external_auth

    temp_token = Token.new
    temp_token.access_token= params[:access_token]
    temp_token.provider = params[:provider]

    if current_user
      temp_user = current_user
    else
      temp_user = User.from_external_token temp_token.access_token, temp_token.provider
    end

    begin
      token = do_external_auth temp_user, temp_token
      sign_in token.user
      redirect_to (request.env['HTTP_REFERER'] || random_questions_path)
    rescue => error
      redirect_to root_path, :flash => {:errors => "Unable to link. This account may be linked with another user."}
    end

  end

  def external_auth

    temp_token = Token.new(params[:token])

    if params[:user][:id] and current_user and current_user.id and current_user.id == params[:user][:id]
      temp_user = User.find params[:user][:id]
    elsif params[:user]
      temp_user = User.new(params[:user])
    else
      temp_user = User.from_external_token temp_token.access_token, temp_token.provider
    end

    begin
      token = do_external_auth temp_user, temp_token
      render :json => token, :include => :user, :methods => [:access_token, :refresh_token], :except => [:hashed_access_token, :hashed_refresh_token]
    rescue => error
      response.status = 400
      render :json => { :error => "Error creating external user or token: #{error}"}
    end
  end


  def destroy
    if current_user and @token
      Token.find_by_unhashed_token(@token).delete
    end
    render :json => {:result => "success"}
  end

  private

  def do_external_auth temp_user, temp_token
    errors = {}
    user = nil

    #validate the token first by pulling the external id for the token
    external_id = ExternalAuthProvider.external_id_for_token temp_token.access_token, temp_token.provider
    if !external_id
      raise "Invalid Token."
      return
    end

    #now, see if this is an existing user, by loading from the user.id or the user email
    if temp_user.id

      #if there is a user id, then load that user.
      user = User.find(temp_user.id)

      #if there is no user id, find users by email
    elsif temp_user.email
      user = User.find_by(:email => temp_user.email)
    end

    #if we havent found a user via the provided id or email, then see if a user is already linked
    if !user
      provider = ExternalAuthProvider.find_by :provider_type =>  temp_token.provider, :provider_id => external_id
      if provider
        user = provider.user
      end
    else
      #if we do have a user, make sure we're not already linked with another user
      if !ExternalAuthProvider.where(:provider_type => temp_token.provider).where(:provider_id => external_id).where.not(:user_id => user.id).empty?
        raise "Account is already linked."
        return
      end
    end

    #if we still don't have a user, then we need to generate a password
    if !user

      #generate a password since it is requred.
      temp_user.password = generated_password
      temp_user.password_confirmation = temp_user.password
      user = temp_user

    end

    #load stuff about the user
    #user.about_me = temp_user.about_me if !user.about_me

    #validate the everything saves correctly and link the new token with the user
    if user.save! and temp_token.user = user and temp_token.save!

      #load an auth record for the provider, user and id if it exists and if not then create our new link
      e = ExternalAuthProvider.find_by :provider_type => temp_token.provider, :user => user, :provider_id => external_id
      if(!e)
        e = ExternalAuthProvider.new
        e.provider_id = external_id
        e.provider_type = temp_token.provider
        e.user = user
        e.save!
      end

      # add all connections between this user and other connected users
      #e.load_connections temp_token.access_token

      #return the token and user.
      return temp_token

    else
      raise "Error creating external user or token"
    end

  end


end
