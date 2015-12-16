class CreateEmailAddresses < ActiveRecord::Migration
  def change
    create_table :email_addresses do |t|
      t.string :email
      t.integer :person_id
      t.boolean :primary, default: false

      t.timestamps null: false
    end
  end
end
