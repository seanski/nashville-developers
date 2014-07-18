class ProfileController < AuthenticatedController
  skip_authorization_check

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.update user_params
    respond_with @user, location: edit_profile_path
  end

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, skill_ids: [])
  end
end
