class SessionsController < ApplicationController
  def show
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
  end

  def update
    # Updating a session means updating its questions
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
    # OK, now update everything in questions that has been marked
    # Can we iterate through params?
    p params
    render :show
  end
end
