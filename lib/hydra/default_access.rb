module Hydra::DefaultAccess

  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    #
    # Returns default permissions for the rightsMetadata datastream of this class
    #
    def default_permissions_hash
      @default_permissions_hash ||= build_default_permissions_hash
    end

    #
    # Constructs permissions hash based on defined role_names and permission_types filtered by class name
    #
    def build_default_permissions_hash
      default_permissions = { 'group' => { 'public' => 'read' } }
      roles = RoleMapper.role_names.select{ |role| role.split('_').last == class_name.downcase }
      roles.each do |role|
        permissions = RoleMapper.permission_types.select{ |permission| role.split('_').first == permission }
        # NOTE it is assumed that there will only be one permission per role
        permissions.each do |permission|
          default_permissions["group"].merge!( { role => permission } )
        end
      end
      default_permissions
    end

  end

end
