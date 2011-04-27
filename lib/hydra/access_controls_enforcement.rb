require "#{RAILS_ROOT}/vendor/plugins/hydra_repository/lib/hydra/access_controls_enforcement.rb"
module Hydra::AccessControlsEnforcement
  private

  # If someone hits the show action while their session's viewing_context is in edit mode, 
  # this will redirect them to the edit action.
  # If they do not have sufficient privileges to edit documents, it will silently switch their session to browse mode.
  def enforce_viewing_context_for_show_requests
    if params[:viewing_context] == "browse"
      session[:viewing_context] = params[:viewing_context]
    elsif session[:viewing_context] == "edit"
      if editor?
        logger.debug("enforce_viewing_context_for_show_requests redirecting to edit")
        if params[:files]
          redirect_to :action=>:edit, :files=>true, :event_id => params[:event_id], :master_id => params[:master_id], :content_type => params[:content_type]
        else
          redirect_to :action=>:edit, :event_id => params[:event_id], :master_id => params[:master_id], :content_type => params[:content_type]
        end
      else
        session[:viewing_context] = "browse"
      end
    end
  end

end
