class SpotsController < ApplicationController

  before_filter :admin_user, :only => [:destroy]

  def new
    @object = Spot.new
  end

  def create
    @object = Spot.new(get_request_as_json params, :spot)

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
    @object = Spot.find(id)

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end

  end

  def edit
    @title = "Edit"
    @object = Spot.find(id = params[:id])

    respond_to do |format|
      format.html  #normal flow
      format.json  { render :json => @object }
    end
  end

  def update
    @object = Spot.find(params[:id])

    if @object.update_attributes(get_request_as_json params, :spot)

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

    @objects = Spot.all

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects}
    end
  end

  def favorites
    @objects = current_user.favorite_spots

    respond_to do |format|
      format.html  #normal flow
      format.json  {render :json => @objects }
    end

  end

  def destroy
    object = Spot.find(params[:id])

    object.destroy

    respond_to do |format|
      format.html  {redirect_to spots_path, :flash => {:success => "Object Deleted"}}
      format.json  {render :json => {:result => "success"}}
    end
  end

end