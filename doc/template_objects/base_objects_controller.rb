class BaseObjectsController < ApplicationController

  def new
    @title = "Add New"
    @object = BaseObject.new
  end


  def create
    @object = BaseObject.new(params[:base_object])
    if @object.save
      redirect_to base_objects_path
    else
      render 'new'
    end
  end

  def show
    @title = 'Details'
    id = params[:id]
    @object = BaseObject.find(id)
  end

  def edit
    @title = "Edit"
    @object = BaseObject.find(id = params[:id])
  end

  def update
    @object = BaseObject.find(params[:id])
    if @object.update_attributes(params[:base_object])
      redirect_to(base_objects_path, :flash => {:success =>"Object Updated."} )
    else
      @title = "Edit"
      render 'edit'
    end
  end

  def index

    #for will_paginate instead of
    #@users = User.all
    @objects = BaseObject.paginate(:page => params[:page])

  end

  def destroy
    BaseObject.find(params[:id]).destroy
    redirect_to base_objects_path, :flash => {:success => "Object Deleted"}
  end

end
