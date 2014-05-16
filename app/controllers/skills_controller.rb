class SkillsController < AuthenticatedController
  load_and_authorize_resource
  
  def index    
    respond_with @skills
  end

  def show
    respond_with @skill
  end

  def new
  
  end

  def create
    @skill.save
    respond_with @skill
  end

  def edit
  end

  def update
    @skill.update(skill_params)
    respond_with @skill
  end

  def destroy
    @skill.destroy
    respond_with @skill
  end  

  private

  def skill_params
    params.require(:skill).permit(:name)
  end
end
