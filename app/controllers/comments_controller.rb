class CommentsController < ApplicationController

  before_filter :authenticate, :only => [:new, :create]
  # before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => [:edit, :update, :destroy]

  def new
    @object = Comment.new

    #load nested resources
    if params[:question_id]
      @target = Question.find(params[:question_id])
      @object.target_id = @target.id
      @object.target_type = RELATIONSHIP_TYPE_QUESTION
    end


  end

  def create
    @object = Comment.new(get_request_as_json params, :comment)

    #load nested resources
    if params[:question_id]
      @target = Question.find(params[:question_id])
      @object.target_id = @target.id
      @object.target_type = RELATIONSHIP_TYPE_QUESTION
    end

    @object.user = current_user

    if @object.save

      respond_to do |format|
        format.html  {redirect_to @object.target}
        format.json  { render :json => @object, :include => :user }
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
    @object = Comment.find(id)

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end

  end

  def edit
    @title = "Edit"
    @object = Comment.find(id = params[:id])

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end
  end

  def update
    #load the user
    if params[:user_id]
      user_id = params[:user_id]
    elsif current_user
      user_id = current_user.id
    end

    #load by id
    if(params[:id])
      @object = Comment.find(params[:id])
    end

    #update the object
    if @object and @object.update_attributes(get_request_as_json params, :comment)

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

    @objects = Comment.all

    #load nested resources
    if params[:question_id]
      @target = Question.find(params[:question_id])
      @objects = @target.comments
    end

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects}
    end
  end

  def destroy

    #load by id
    if(params[:id])
      object = Comment.find(params[:id])
    end

    object.destroy

    respond_to do |format|
      format.html  {redirect_to comments_path, :flash => {:success => "Object Deleted"}}
      format.json  {render :json => {:result => "success"}}
    end
  end

end