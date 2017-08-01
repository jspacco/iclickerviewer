class QuestionsController < ApplicationController
  include ApplicationHelper

  def show
    question = Question.find_by(id: params[:id])
    @questions = [question]
    # pair question, if any
    pair = Question.find_by(class_period: question.class_period_id,
      question_type: 3, question_pair: question.question_index)
    if pair != nil
      @questions << pair
    end
    puts @questions

    # Look up the class period, course, and questions
    @class_period = ClassPeriod.find_by(id: question.class_period_id)
    @course = Course.find_by(id: @class_period.course_id)
    # For making a link to the next question.
    @next_question = Question.where("question_index > ? and class_period_id = ?",
      question.question_index, question.class_period_id).first

    # TODO: use precomputed text files to find potential matches
    # TODO: pull information out of slides

  end
end
