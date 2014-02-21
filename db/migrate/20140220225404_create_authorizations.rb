class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations do |t|
      t.references :user, index: true
      t.string :provider
      t.string :provided_id
      t.string :token
      t.string :secret

      t.timestamps
    end
  end
end
