class Ability
  include CanCan::Ability

  def initialize(user)
    if user.has_role? 'admin'
      can :manage, :all
      can :bob, User
    end

    if user.has_role? 'staff'
      can [:create, :read, :update, :delete], User
      can :view_skills, User
      can :manage, Skill
    end

    can [:read, :create], Skill
  end
end
