class QuestionsController < ApplicationController

  before_filter :admin_user, :only => [:new, :create, :edit, :update, :destroy]

  def new
    @object = Question.new
  end

  def create
    @object = Question.new(get_request_as_json params, :question)

    if @object.save

      respond_to do |format|
        format.html  {redirect_to @object}
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
    @object = Question.find(id)

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object, :include => [{:comments => {:include => :user}}, :ratings,], :user_id => current_user_id }
    end

  end

  def edit
    @title = "Edit"
    @object = Question.find(id = params[:id])

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end
  end

  def update
    @object = Question.find(params[:id])

    if @object.update_attributes(get_request_as_json params, :question)

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

    @objects = Question.all

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects, :include => [{:comments => {:include => :user}}, ], :user_id => current_user_id}
    end
  end

  def favorites
    @objects = current_user.favorite_questions

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects, :include => [{:comments => {:include => :user}}], :user_id => current_user_id }
    end

  end

  def destroy
    object = Question.find(params[:id])

    object.destroy

    respond_to do |format|
      format.html  {redirect_to questions_path, :flash => {:success => "Object Deleted"}}
      format.json  {render :json => {:result => "success"}}
    end
  end

end