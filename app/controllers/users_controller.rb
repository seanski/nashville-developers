class UsersController < AuthenticatedController
  load_and_authorize_resource
  
  def index
    if q = params[:q]      
      @search = User.search(q, misspellings: {distance: 4}, suggest: true)
      @users = @users.where(id: @search.map(&:id))
    end    
        
    respond_with @users
  end

  def show
    respond_with @user
  end

  def new
  
  end

  def create
    @user.save
    respond_with @user
  end

  def edit
  end

  def update
    @user.update(user_params)
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end  

  private

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, skill_ids: [])
  end
end
