class RoleMapper

  def self.role_names
    Group.hydra_group_names
  end

  def self.roles(username)
    User.find_by_login(username).hydra_group_names rescue []
  end

  def self.whois(group_name)
    User.user_names_in_hydra_group(Group.find_by_name(group_name)) rescue []
  end

end
