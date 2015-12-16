module Fe
  # prefix for database tables
  mattr_accessor :table_name_prefix
  self.table_name_prefix = 'fe_'
  
  mattr_accessor :answer_sheet_class
  self.answer_sheet_class = 'Fe::Application'
  
  mattr_accessor :from_email
  self.from_email = 'fe@fe.com'

  mattr_accessor :never_reuse_elements
  self.never_reuse_elements = true
end
