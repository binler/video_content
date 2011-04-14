module ApplicationHelper

  require_dependency 'vendor/plugins/blacklight/app/helpers/application_helper.rb'
  require_dependency 'vendor/plugins/hydra_repository/app/helpers/application_helper.rb'

  def application_name
    'Hydrangea'
  end

  def icon_masquerade_link(user)
    link_to image_tag('/stylesheets/icons/masquerade.png', :alt =>'Masquerade', :title => 'Masquerade'), start_masquerade_path(user), { :class => 'icon-link' }
  end

end
