class SessionsController < ApplicationController
  def show
    get_questions_course_session
  end

  def update
    Question.where(session_id: params[:id]).each do |question|
      # x = params[:questions][question.id]
      # puts "FOO %s FOO" % question.id
      # puts "BAR %s BAR" % params[:questions].keys
      # puts "BAZ %s BAZ" % params[:questions].values
      # puts "BAN %s BAN" % params[:questions][question.id.to_s]
      question.update_attributes(question_params(question))
    end


    # Update every question containing at least one correct answer checked
    # FIXME This will not work for clicker questions that have no correct answers,
    #   because unchecking all checkboxed will not show up in the post/patch params
    #   at all.
    # params[:correct_answers].each do |question_id, answers|
    #   question = Question.find_by(id: question_id)
    #   # First, assign all correct answers to 0
    #   question.correct_a = question.correct_b = question.correct_c =
    #     question.correct_d = question.correct_e = 0
    #   # Now, re-assign any answers listed as correct answers to 1
    #   answers.each do |ans|
    #     case ans
    #     when 'a', 'A'
    #       question.correct_a = 1
    #     when 'b', 'B'
    #       question.correct_b = 1
    #     when 'c', 'C'
    #       question.correct_c = 1
    #     when 'd', 'D'
    #       question.correct_d = 1
    #     when 'e', 'E'
    #       question.correct_e = 1
    #     end
    #   end
    #   question.save
    # end

    # Finally, look up the course, session, and questions we just updated to make
    #   them available to to the view. We are going to re-direct to the show view,
    #   but NOT the show controller.
    get_questions_course_session

    # Basically, this is a re-direct ONLY for rendering!
    #   It does NOT call the show method in this file.
    render :show
  end

  private

  def question_params(question)
    return params.require(:questions).require(question.id.to_s).permit(:correct_a,
      :correct_b, :correct_c, :correct_d, :correct_e, :question_type)
  end

  def get_questions_course_session
    # Look up the session, course, and questions
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
    # Average time taken per clicker question
    total_time = 0.0
    num_questions = 0.0
    @questions.each do |q|
      total_time += q.num_seconds
      num_questions += 1
    end
    @avg_time = (total_time / num_questions).round(0)

  end
end
