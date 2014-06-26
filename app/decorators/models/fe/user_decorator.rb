Fe::User.class_eval do
  # an example of how to change the Fe::User table name
  self.table_name = "fe_users"

  # add app-specific methods to Fe::User here
end

