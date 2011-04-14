class RoleMapper

  def self.role_names
    Group.hydra_group_names
  end

  def self.roles(username)
    begin
      User.find_by_login(username).hydra_group_names
    rescue ActiveRecord::Error
      []
    end
  end

  def self.whois(group_name)
    begin
      User.user_names_in_hydra_group(Group.find_by_name(group_name))
    rescue ActiveRecord::Error
      []
    end
  end

end
