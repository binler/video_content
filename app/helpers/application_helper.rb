module ApplicationHelper

  require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
  require_dependency 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'

  def application_name
    'Hydrangea'
  end

  def submit_button_message
    if params[:action].blank? || params[:controller].blank?
      "Save"
    else
      model = params[:controller].humanize.singularize
      case params[:action]
      when "new"
        "Create #{model}"
      when "edit"
        "Update #{model}"
      end
    end
  end
  
  def cancel_button_message
    if params[:action].blank? || params[:controller].blank?
      "Cancel"
    else
      model = params[:controller].humanize.singularize
      case params[:action]
      when "new"
        "Return to #{model} Listing"
      when "edit"
        "Discard Changes to #{model}"
      end
    end
  end

  def icon_masquerade_link(user)
    link_to image_tag('/images/masquerade.png', :alt =>'Masquerade', :title => 'Masquerade'), start_masquerade_path(user), { :class => 'icon-link' }
  end

  def edit_and_browse_links
    result = ""
    if params[:action] == "edit"
      result << "<a href=\"#{catalog_path(@document[:id], :viewing_context=>"browse", :content_type=>params["content_type"])}\" class=\"browse toggle\">Browse</a>"
      result << "<span class=\"edit toggle active\">Edit</span>"
    else
      result << "<span class=\"browse toggle active\">Browse</span>"
      result << "<a href=\"#{edit_catalog_path(@document[:id], :content_type=>params["content_type"])}\" class=\"edit toggle\">Edit</a>"
    end
    # result << link_to "Browse", "#", :class=>"browse"
    # result << link_to "Edit", edit_document_path(@document[:id]), :class=>"edit"
    return result
  end

end
