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

  def build_lucene_query(user_query)
    q = ""
    # start query of with user supplied query term
      q << "_query_:\"{!dismax qf=$qf_dismax pf=$pf_dismax}#{user_query}\""

    # Append the exclusion of FileAssets
      q << " AND NOT _query_:\"info\\\\:fedora/afmodel\\\\:FileAsset\""

    # Append the query responsible for adding the users discovery level
      permission_types = RoleMapper.permission_types
      field_queries = []
      embargo_query = ""
      permission_types.each do |type|
        field_queries << "_query_:\"#{type}_access_group_t:public\""
      end

      unless current_user.nil?
        # Role scope is limited by permission type
        RoleMapper.roles(current_ability).each do |role|
          permission_types.each do |type|
            field_queries << "_query_:\"#{type}_access_group_t:#{role}\"" if role.split('_').first == type
          end
        end
        # for individual person access
        permission_types.each do |type|
          field_queries << "_query_:\"#{type}_access_person_t:#{current_user.login}\""
        end
        if current_user.is_being_superuser?(session)
          permission_types.each do |type|
            field_queries << "_query_:\"#{type}_access_person_t:[* TO *]\""
          end
        end

        # if it is the depositor and it is under embargo, that is ok
        # otherwise if it not the depositor and it is under embargo, don't show it
        embargo_query = " OR  ((_query_:\"embargo_release_date_dt:[NOW TO *]\" AND  _query_:\"depositor_t:#{current_user.login}\") AND NOT (NOT _query_:\"depositor_t:#{current_user.login}\" AND _query_:\"embargo_release_date_dt:[NOW TO *]\"))"
      end

      # remove anything with an embargo release date in the future
      # embargo_query = " AND NOT _query_:\"embargo_release_date_dt:[NOW TO *]\"" if embargo_query.blank?
      field_queries << " NOT _query_:\"embargo_release_date_dt:[NOW TO *]\"" if embargo_query.blank?

      q << " AND (#{field_queries.join(" OR ")})"
      q << embargo_query
      return q
  end

end
