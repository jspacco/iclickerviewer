class QuestionsController < ApplicationController
  include ApplicationHelper

  # -------------------------------------------------------------
  # POST /questions/1
  def update
    question = Question.find_by(id: params[:id])

    update_matches_question(:possible_matches)
    update_matches_question(:nonmatches)
    update_matches_question(:matches)

    redirect_to action: :show, id: params[:id]
  end

  # -------------------------------------------------------------
  # GET /questions/1
  def show
    get_values
  end

  private

  # -------------------------------------------------------------
  def update_matches_question(key)
    return if not params.has_key?(key)
    params[key].each do |poss_match_id, options|
      is_match = nil_if_blank(options[:is_match])
      match_type = nil_if_blank(options[:match_type])
      # puts "is_match? #{is_match}, match_type: #{match_type}"
      matching_questions = MatchingQuestion.where(question_id: params[:id], matching_question_id: poss_match_id).
        or(MatchingQuestion.where(question_id: poss_match_id, matching_question_id: params[:id]))
      matching_questions.each do |mq|
        # puts "matching thing: #{mq.question_id} #{mq.matching_question_id} #{mq.is_match} #{mq.match_type}"
        mq.is_match = is_match # if is_match
        mq.match_type = match_type # if match_type
        mq.save
      end
    end
  end

  def get_values
    question = Question.find_by(id: params[:id])
    @questions = [question]
    question_ids = [question.id]
    # pair question, if any
    pair = Question.find_by(class_period: question.class_period_id,
      question_type: 3, question_pair: question.question_index)
    if pair != nil
      @questions << pair
      question_ids << pair.id
    end

    # Look up the class period, course, and questions
    @class_period = ClassPeriod.find_by(id: question.class_period_id)
    @course = Course.find_by(id: @class_period.course_id)
    # For making a link to the next question.
    @next_question = Question.where("question_index > ? and class_period_id = ?",
      question.question_index, question.class_period_id).first

    # Don't include potential matches with the current question (since every question
    # obviously matches itself) or questions in the current class period
    # (since those are more likely to be paired votes rather than matches)
    #
    @possible_matches = question.matched_questions.where(:matching_questions => {:is_match => nil}).
      where.not(id: question_ids).
      where.not(class_period: @class_period)
    @matched_questions = question.matched_questions.where(:matching_questions => {:is_match => 1}).
      where.not(id: question_ids).
      where.not(class_period: @class_period)
    @nonmatching_questions = question.matched_questions.where(:matching_questions => {:is_match => 0}).
      where.not(id: question_ids).
      where.not(class_period: @class_period)

    # TODO: pull information out of slides
  end
end
