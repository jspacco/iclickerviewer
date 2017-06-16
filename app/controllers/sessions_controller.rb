class SessionsController < ApplicationController
  def show
    p "OK, totally calling sessions#show!"
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
  end

  def update
    # Updating a session means updating its questions
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)

    # Update all of the questions
    params[:correct_answers].each do |question_id, answers|
      question = Question.find_by(id: question_id)
      # First, assign all correct answers to 0
      question.correct_a = question.correct_b = question.correct_c =
        question.correct_d = question.correct_e = 0
      # Now, re-assign any answers listed as correct answers to 1
      answers.each do |ans|
        case ans
        when 'a'
          question.correct_a = 1
        when 'b'
          question.correct_b = 1
        when 'c'
          question.correct_c = 1
        when 'd'
          question.correct_d = 1
        when 'e'
          question.correct_e = 1
        end
      end
      question.save
    end

    # Finally, look up the questions we just updated to make them available to
    #   to the view
    @questions = Question.where(session_id: @session.id)

    # Basically, this is a re-direct back to sessions#show
    render :show
  end
end
