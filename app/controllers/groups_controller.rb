class GroupsController < ApplicationController
  before_filter :require_login
  load_and_authorize_resource

  # GET /groups
  # GET /groups.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/1/edit
  def edit
  end

  # POST /groups
  # POST /groups.xml
  def create
    if params.include?('Cancel')
      redirect_to groups_path
    else
      respond_to do |format|
        if @group.save
          flash[:notice] = 'Group was successfully created.'
          format.html { redirect_to(@group) }
          format.xml  { render :xml => @group, :status => :created, :location => @group }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    if params.include?('Cancel')
      redirect_to @group 
    else
      respond_to do |format|
        if @group.update_attributes(params[:group])
          flash[:notice] = 'Group was successfully updated.'
          format.html { redirect_to(@group) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
end
