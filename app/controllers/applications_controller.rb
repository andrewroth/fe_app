class ApplicationsController < ApplicationController
  def index
    @question_sheets = Fe::QuestionSheet.all
  end

  def create
    sheet = Fe::QuestionSheet.find(params[:question_sheet_id])
    app = current_person.applications.create!
    app.question_sheets << sheet
    redirect_to edit_fe_answer_sheet_path(app)
  end
end
