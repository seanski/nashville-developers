class CreateUserSkills < ActiveRecord::Migration
  def change
    create_table :user_skills do |t|
      t.references :user, index: true
      t.references :skill, index: true

      t.timestamps
    end
  end
end
