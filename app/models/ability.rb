class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? 'admin'
      can :manage, :all
    end

    if user.has_role? 'staff'
      can :read, User
    end
  end
end
