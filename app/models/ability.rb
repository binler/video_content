class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in) 
    # Load all Permissions for workflow actions
    if user.login?
      Action.permissible_class_actions_for_login(user.login).each do |action|
        can action.name.to_sym, action.permissible_type.constantize
      end
      # NOTE although it is possible to grant CanCan permissions on a instance by instance basis
      # it is not currently implemented. If it IS enabled individual permissions will need to be
      # retrieved from the database.
      # Action.permissible_instance_actions_for_login(user.login).each do |action|
      #   can action.name.to_sym, action.permissible_type.constantize, :id => permissible_id.to_i
      # end
    end

    # Defining abilities in the database can be augmented with abilities defined in CanCan DSL
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    # https://github.com/ryanb/cancan/wiki/Abilities-in-Database

    if user.in_group? :root
      can :manage, :all
      can :masquerade, User
      can :manage_abilities, Group
      cannot :destroy, Group, :for_cancan => true

      Workflow.control_classes.each do |klass|
        klass.permissible_actions.each do |action|
          can action, klass
        end
      end
    else
      can :read, :all
    end
  end
end
