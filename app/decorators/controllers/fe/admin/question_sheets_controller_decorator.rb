Fe::Admin::QuestionSheetsController.class_eval do
  prepend_before_action :authenticate_user!
end
