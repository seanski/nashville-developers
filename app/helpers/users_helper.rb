module UsersHelper
  def display_roles(roles)
    roles.map(&:name).join(', ')
  end

  def display_skills(skills)
    skills.map(&:name).join(', ')
  end
end
