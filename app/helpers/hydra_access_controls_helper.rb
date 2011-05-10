module HydraAccessControlsHelper
  require_dependency 'vendor/plugins/hydra_repository/app/helpers/hydra_access_controls_helper.rb'

  def test_permission(permission_type)
    # if !current_user.nil?
    if (@document == nil)
      logger.warn("SolrDocument is nil")
    end

    if current_user.nil?
      user_login = "public"
      logger.debug("current_user is nil, assigning public")
    else
      user_login = current_user.login
    end

    user_groups = RoleMapper.roles(current_ability)
    # everyone is automatically a member of the group 'public'
    user_groups.push 'public' unless user_groups.include?('public')
    # logged-in users are automatically members of the group "registered"
    user_groups.push 'registered' unless user_login == "public"

    logger.debug("User #{user_login} is a member of groups: #{user_groups.inspect}")
    case permission_type
    when :edit
      logger.debug("Checking edit permissions for user: #{user_login}")
      group_intersection = user_groups & edit_groups
      result = !group_intersection.empty? || edit_persons.include?(user_login)
    when :read
      logger.debug("Checking read permissions for user: #{user_login}")
      group_intersection = user_groups & read_groups
      result = !group_intersection.empty? || read_persons.include?(user_login)
    else
      result = false
    end
    logger.debug("test_permission result: #{result}")
    return result
  end

end
