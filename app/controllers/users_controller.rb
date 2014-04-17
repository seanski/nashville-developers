class UsersController < AuthenticatedController
  load_and_authorize_resource  

  def index    
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
    @user.update(params[:user])
    respond_with @user
  end

  def destroy
    @user.destroy
    respond_with @user
  end  
end
