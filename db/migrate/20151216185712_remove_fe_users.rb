class RemoveFeUsers < ActiveRecord::Migration
  def change
    drop_table :fe_users
  end
end
