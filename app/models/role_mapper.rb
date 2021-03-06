class RoleMapper

  def self.role_names
    Workflow.hydra_role_names
  end

  def self.permission_types
    @@permission_types ||= ['discover','read','edit']
  end

  def self.roles(target)
    ability = target
    begin
      unless target.respond_to?(:can?)
        user = User.find_by_login(username)
        raise "No user found with username: #{username}" if user.nil?
        ability = Ability.new(user)
      end
      # NOTE: the construction of role names is tightly coupled with the applicable class name
      role_names.select{ |role| ability.can? role.to_sym, "#{role.split('_').last.titleize}Workflow".constantize }
    rescue
      []
    end
  end

  # NOTE this method will only return logins for users assigned to groups where
  # their permissions have been granted explicitly to Classes. Instance assignments
  # are not tracked nor are permissions defined by CanCan rules e.g. root users.
  def self.whois(action)
    User.logins_permitted_to_perform_action(action).map{|u| u.login}.uniq rescue []
  end

end
