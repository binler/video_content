require 'casclient'
require 'casclient/frameworks/rails/filter'

class UserSessionsController < ApplicationController
  before_filter ::CASClient::Frameworks::Rails::Filter, :only => :new unless RAILS_ENV == "test"

  def new
    @user_session = UserSession.new
    session['target_path'] ? redirect_to( session['target_path'] ) : redirect_to( root_path )
  end

  def destroy
    current_user_session.destroy rescue nil
    reset_session
  end

end
