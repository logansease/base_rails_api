class PagesController < ApplicationController  

  include SessionsHelper
  before_filter :check_admin, :only => [:admin, :new, :create, :edit, :update]

  def new
      @title = "Add New"
      @object = Page.new
    end

    def create
      @object = Page.new(params[:page])
      if @object.save
        redirect_to pages_path
      else
        render 'new'
      end
    end

    def show
      @object = Page.find_by_title(params[:id])
      if !@object
        redirect_to(root_path, :flash => {:failure =>"That page was not found."} )
      end
    end

    def edit
      @title = "Edit"
      @object = Page.find_by_title(params[:id])
    end

    def update
      @object = Page.find_by_title(params[:id])
      if @object.update_attributes(params[:page])
        redirect_to(pages_path, :flash => {:success =>"Object Updated."} )
      else
        @title = "Edit"
        render 'edit'
      end
    end

    def index

      #for will_paginate instead of
      #@users = User.all
      @pages = Page.paginate(:page => params[:page])

    end

    def destroy
      Page.find_by_title(params[:id]).destroy
      redirect_to page_path, :flash => {:success => "Object Deleted"}
    end

  def admin
    #@ads = Advertisement.where("start_date is null")
    @user_count = User.count
 end

  def error

  end

  def maintenance

  end

  def site_map
    @pages = Page.all
    render "site_map", :layout => false
  end

  def site_map_xml
    @pages = Page.all
     render "site_map_xml", :layout => false
  end



  def home    
    @title = "Home"

    if signed_in?  

    end
  end

  def contact  
    @title = "Contact" 
  end      
  
  def about  
    @title = "About" 
  end

end
