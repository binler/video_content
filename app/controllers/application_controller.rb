require_dependency 'vendor/plugins/blacklight/app/controllers/application_controller.rb'
require_dependency 'vendor/plugins/hydra_repository/app/controllers/application_controller.rb'
class ApplicationController < ActionController::Base
  
  # Defining methods here does not override the methods defined in vendor/plugins/hydra_repository/app/controllers/application_controller.rb every time they are called.
  # Specifically default_html_head and current_user were behaving erratically. I believe the before_filter calling those methods is the culprit.
  # It appears that the first time the method is called it is executed from this class but subsequent calls fall to the hydra_repository ApplicationController

  def require_login
    session['target_path'] = request.path_info
    current_user ? true : redirect_to( login_path )
  end
end
