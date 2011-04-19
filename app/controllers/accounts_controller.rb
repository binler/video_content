class AccountsController < ApplicationController
  before_filter :require_login
  load_and_authorize_resource :class => 'User'

  # GET /accounts
  # GET /accounts.xml
  def index
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @accounts }
    end
  end

  # GET /accounts/1
  # GET /accounts/1.xml
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/new
  # GET /accounts/new.xml
  def new
    @post_action = {:controller => 'accounts', :action => 'create' }
    @available_groups = Group.accessible_by(current_ability, :manage)
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @account }
    end
  end

  # GET /accounts/1/edit
  def edit
    @post_action = {:controller => 'accounts', :action => 'update' }
    @available_groups = Group.accessible_by(current_ability, :manage)
  end

  # POST /accounts
  # POST /accounts.xml
  def create
    if params.include?('Cancel')
      redirect_to accounts_path
    else
      respond_to do |format|
        if @account.save
          flash[:notice] = 'Account was successfully created.'
          format.html { redirect_to(account_path(@account.id)) }
          format.xml  { render :xml => @account, :status => :created, :location => @account }
        else
          format.html { render :action => "new" }
          format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # PUT /accounts/1
  # PUT /accounts/1.xml
  def update
    if params.include?('Cancel')
      redirect_to account_path(@account.id)
    else
      # If all groups are removed from an account the group_ids attribute is not passed to params
      params[:account][:group_ids] ? @account.no_groups_selected = false : @account.no_groups_selected = true

      respond_to do |format|
        if @account.update_attributes(params[:account])
          flash[:notice] = 'Account was successfully updated.'
          format.html { redirect_to(account_path(@account.id)) }
          format.xml  { head :ok }
        else
          format.html { render :action => "edit" }
          format.xml  { render :xml => @account.errors, :status => :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /accounts/1
  # DELETE /accounts/1.xml
  def destroy
    @account.destroy

    respond_to do |format|
      format.html { redirect_to(accounts_url) }
      format.xml  { head :ok }
    end
  end
end
