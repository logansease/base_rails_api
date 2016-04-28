 require 'digest/md5'

class SessionsController < ApplicationController
  
  def new 
    @title = "Sign in"
  end
  
  def create

    user = User.authenticate(params[:session][:email], params[:session][:password])
    if user.nil?          
      @title = "Sign in"
      flash.now[:error] = "Invalid email / password combination"       
      #note the flash.now makes the error persist only now, NOT for the next request,
      #since as noted below we are not moving to a new request
      render 'new'  #note this is not a new request
    else
      if !user.activated
        session['activate_id'] = user.id
        redirect_to '/users/send_activation'
      else
        sign_in user
        redirect_back_or(user) #helper mtd
      end
    end
  end
  
  def destroy
     sign_out
     redirect_to root_path
  end  
 
end
