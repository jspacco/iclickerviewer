class SessionsController < ApplicationController
  def show
    get_questions_course_session
  end

  def update
    # Update every question with at least one answer checked
    # FIXME This will not work for clicker questions that have no correct answers,
    #   because unchecking all checkboxed will not show up in the post/patch params
    #   at alll.
    params[:correct_answers].each do |question_id, answers|
      question = Question.find_by(id: question_id)
      # First, assign all correct answers to 0
      question.correct_a = question.correct_b = question.correct_c =
        question.correct_d = question.correct_e = 0
      # Now, re-assign any answers listed as correct answers to 1
      answers.each do |ans|
        case ans
        when 'a', 'A'
          question.correct_a = 1
        when 'b', 'B'
          question.correct_b = 1
        when 'c', 'C'
          question.correct_c = 1
        when 'd', 'D'
          question.correct_d = 1
        when 'e', 'E'
          question.correct_e = 1
        end
      end
      question.save
    end

    # Finally, look up the course, session, and questions we just updated to make
    #   them available to to the view. We are going to re-direct to the show view,
    #   but NOT the show controller.
    get_questions_course_session

    # Basically, this is a re-direct ONLY for rendering!
    #   It does NOT call call the show method in this file.
    render :show
  end
  private
  def get_questions_course_session
    # Look up the session, course, and questions
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
  end
end
