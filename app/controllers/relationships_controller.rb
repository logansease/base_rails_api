class RelationshipsController < ApplicationController

  #TODO permissions

  def create
    relationship = Relationship.new(get_request_as_json params, :relationship)

    #set the target based on id provided
    if params[:spot_id]
      relationship.target_id = params[:spot_id]
      relationship.target_type = RELATIONSHIP_TYPE_SPOT
    end

    #set the user
    relationship.follower = current_user

    #hold on to our variables for future ajax calls
    @object = relationship.target
    @target_id = relationship[:target_id]
    @target_type = relationship[:target_type]

    if relationship.save

      respond_to do |format|
        format.html  {redirect_to relationship.target }
        format.json  { render :json => relationship }
        format.js # if no block, it will execute action_name.js.erb
      end

    else
      respond_to do |format|
        format.html  {render 'new'}
        format.json  { render :json => {:result => "Error"} }
      end
    end
  end

  def show

    if params[:spot_id] and current_user
      @object = Relationship.find_by :target_type => RELATIONSHIP_TYPE_SPOT, :user_id => current_user.id, :target_id => params[:spot_id]
    end

    respond_to do |format|
      format.html  {render @object}
      format.json  { render :json => @object }
    end
  end

  def destroy

    #load the user
    if params[:user_id]
      user_id = params[:user_id]
    elsif current_user
      user_id = current_user.id
    end

    #load by id
    if(params[:id])
      object = Relationship.find(params[:id])

    #load for menu item
    elsif params[:spot_id]
      object = Relationship.find_by(:target_id => params[:spot_id], :target_type => RELATIONSHIP_TYPE_SPOT, :user_id => user_id)
    end

    #hold on to our variables for future ajax calls
    @target_id = object.target_id
    @target_type = object.target_type
    @object = object.target

    object.destroy

    respond_to do |format|
      format.html  {redirect_to :back, :flash => {:success => "Object Deleted"}}
      format.json  {render :json => {:result => "success"}}
      format.js # if no block, it will execute action_name.js.erb
    end
  end

end