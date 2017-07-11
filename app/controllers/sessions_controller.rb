class SessionsController < ApplicationController
  def show
    get_questions_course_session
  end

  def update
    Question.where(session_id: params[:id]).each do |question|
      question.update_attributes(question_params(question))
      # TODO more elegant way to create self-referential many-to-many
      matching_question_id = params[:questions][question.id.to_s][:matching_questions]
      if matching_question_id != nil
        # Create matching questions in both directions if they don't already exist.
        # [question_id, matching_question_id] and [matching_question_id, question_id]
        MatchingQuestion.find_or_create_by(question_id: question.id,
          matching_question_id: matching_question_id)
        MatchingQuestion.find_or_create_by(question_id: matching_question_id,
          matching_question_id: question.id)
      end
    end
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
    # FIXME Is setting empty strings to nil even necessary?
    if params[:questions][question.id.to_s][:question_pair] == ""
      params[:questions][question.id.to_s][:question_pair] = nil
    end

    # TODO Document require vs permit, as well as how :questions gets us the array.
    return params.require(:questions).require(question.id.to_s).permit(:correct_a,
      :correct_b, :correct_c, :correct_d, :correct_e, :question_type, :question_pair)
  end

  def get_questions_course_session
    # Look up the session, course, and questions
    @session = Session.find_by(id: params[:id])
    @course = Course.find_by(id: @session.course_id)
    @questions = Question.where(session_id: @session.id)
    @all_questions = []
    Question.find_each do |q|
      # @all_questions.push([q.id.to_s, q.id.to_s])
      @all_questions.push(q)
    end
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
