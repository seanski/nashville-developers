module UsersHelper
  def display_roles(roles)
    roles.map(&:name).join(', ')
  end
end
