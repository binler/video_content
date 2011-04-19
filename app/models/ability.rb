class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in) 
    if user.in_group? :root
      can :manage, :all
      can :masquerade, User
      cannot :destroy, Group, :for_cancan => true
    else
      can :read, :all
    end
  end
end
