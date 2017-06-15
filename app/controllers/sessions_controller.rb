class SessionsController < ApplicationController
  def show
    @session = Session.find_by(params[:id])
    @course = Course.find_by(@session.course_id.to_s)
    @questions = Question.where(session_id: @session.id)
  end
end
