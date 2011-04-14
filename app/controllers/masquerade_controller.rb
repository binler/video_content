class MasqueradeController < ApplicationController

  # GET admin/masquerade/start/:user_id
  def start
    authorize! :masquerade, current_user
    begin
      session[:user_the_masquerade] = User.find(params[:user_id]).login
      redirect_to root_path
    rescue ActiveRecord::RecordNotFound
      redirect_to root_path
    end
  end

  # GET admin/masquerade/stop
  def stop
    session[:user_the_masquerade] = nil
    redirect_to root_path
  end
end
