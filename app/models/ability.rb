class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in) 
    # Permissions for workflow actions
    can do |action, subject_class, subject|
      user.permissible_actions_on(subject_class, subject).include? action
    end

    # Defining abilties in the database can be augemented with abilities defined in cancan DSL
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
    # https://github.com/ryanb/cancan/wiki/Abilities-in-Database

    if user.in_group? :root
      can :manage, :all
      can :masquerade, User
      cannot :destroy, Group, :for_cancan => true

      EventWorkflow.permissible_actions.each do |action|
        can action, EventWorkflow
      end
    else
      can :read, :all
    end
  end
end
