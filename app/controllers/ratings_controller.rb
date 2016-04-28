class RatingsController < ApplicationController

  before_filter :authenticate, :only => [:new, :create]
 # before_filter :correct_user, :only => [:show,:edit, :update]
  before_filter :admin_user, :only => [:edit, :update, :destroy]

  def new
    @object = Rating.new

    #set the target based on id provided
    if params[:question_id]
      @object.target_id = params[:question_id]
      @object.target_type = RELATIONSHIP_TYPE_QUESTION
    end

  end

  def create
    @object = Rating.new(get_request_as_json params, :rating)

    #set the target based on id provided
    if params[:question_id]
      @object.target_id = params[:question_id]
      @object.target_type = RELATIONSHIP_TYPE_QUESTION
    end

    if params[:user_id]
      @object.user = User.find(params[:user_id])
    else
      @object.user = current_user
    end

    if @object.save

      respond_to do |format|
        format.html  {redirect_to @object.target}
        format.json  { render :json => @object }
      end

    else
      respond_to do |format|
        format.html  {render 'new'}
        format.json  { render :json => {:result => "Error"} }
      end
    end
  end

  def show
    @title = 'Details'
    id = params[:id]
    @object = Rating.find(id)

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end

  end

  def edit
    @title = "Edit"
    @object = Rating.find(id = params[:id])

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end
  end

  def update

    if params[:user_id]
      user_id = User.find(params[:user_id])
    else
      user_id = current_user
    end

    #load by id
    if(params[:id])
      @object = Rating.find(params[:id])

      #load for the menu item
    elsif params[:question_id]
      objects = Rating.where(:target_id => params[:question_id]).where(:target_type => RELATIONSHIP_TYPE_QUESTION).where(:user_id => user_id)
      if objects and objects.count > 0
        @object = objects.first
      end
    end

    if @object.update_attributes(get_request_as_json params, :rating)

      respond_to do |format|
        format.html  {redirect_to @object}
        format.json  { render :json => @object }
      end

    else
      respond_to do |format|
        format.html  {render 'edit'}
        format.json  { render :json => {:result => "Error"} }
      end
    end
  end

  def index

    @objects = Rating.all

    if params[:question_id]
      @objects = @objects.where(:target_id => params[:question_id]).where(:target_type => RELATIONSHIP_TYPE_QUESTION)
      @question = Question.find params[:question_id]
    end

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects}
    end
  end

  def destroy

    if params[:user_id]
      user_id = User.find(params[:user_id])
    else
      user_id = current_user
    end

    #load by id
    if(params[:id])
      object = Rating.find(params[:id])

      #load for the menu item
    elsif params[:question_id]
      objects = Rating.where(:target_id => params[:question_id]).where(:target_type => RELATIONSHIP_TYPE_QUESTION).where(:user_id => user_id)
      if objects and objects.count > 0
        object = objects.first
      end

    end

    object.destroy

    respond_to do |format|
      format.html  {redirect_to ratings_path, :flash => {:success => "Object Deleted"}}
      format.json  {render :json => {:result => "success"}}
    end
  end

end