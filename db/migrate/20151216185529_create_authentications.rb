class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :person_id
      t.string :provider
      t.string :uid
      t.string :token
      t.timestamp :last_login
      t.string :username

      t.timestamps null: false
    end
  end
end
