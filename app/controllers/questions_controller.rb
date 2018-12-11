class QuestionsController < ApplicationController
  include ApplicationHelper

  # -------------------------------------------------------------
  # POST /questions/1
  def update
    question = Question.find_by(id: params[:id])

    # Edit matching questions where we set a different match_type
    puts "CONTROLLER GO"
=begin
{"questions"=>
  {"6032"=>{"is_match"=>"1",
          "match_type"=>"2",
          "set_changed_q_p"=>"1"},
  "6168"=>{"is_match"=>""}
}
=end
    matches = MatchingQuestion.where(question_id: params[:id])
    matches.each do |mq|
      to_edit = params[:questions][mq.matching_question_id.to_s]
      if to_edit
        if to_edit.key? :is_match
          # TODO update is_match in
          is_match = to_edit[:is_match]
          mq.is_match = is_match == '' ? nil : is_match
        end
        if to_edit.key? :match_type
          match_type = to_edit[:match_type].to_i
          mq.match_type = match_type
          if match_type == 0 or match_type == 1
            # TODO should we turn off modified+ categories in this case?
            # {'changed_question_phrasing'   => 'q_p',
            #  'changed_question_values'     => 'q_v',
            #  'changed_info_phrasing'       => 'i_p',
            #  'changed_info_layout'         => 'i_l',
            #  'changed_answers_phrasing'    => 'a_p',
            #  'changed_answers_values'      => 'a_v',
            #  'changed_answers_order'       => 'a_o',
            #  'changed_answers_type'        => 'a_t',
            #  'changed_other'               => 'o'
            # }.each do |field_name, field_code|
            #   mq[field_code] = 0
            # end
          elsif match_type == 2
            # check for changes to modified+ expanded match categories
            {'changed_question_phrasing'   => 'q_p',
             'changed_question_values'     => 'q_v',
             'changed_info_phrasing'       => 'i_p',
             'changed_info_layout'         => 'i_l',
             'changed_answers_phrasing'    => 'a_p',
             'changed_answers_values'      => 'a_v',
             'changed_answers_order'       => 'a_o',
             'changed_answers_type'        => 'a_t',
             'changed_other'               => 'o'
            }.each do |field_name, field_code|
              changed_field = to_edit["set_changed_#{field_code}"]
              if changed_field
                puts changed_field
                mq[field_name] = changed_field.to_i
                if(changed_field.to_i == 1)
                  # setting any modified+ features implies match_type modified+
                  mq.match_type = 2;
                end
              else
                # TODO is this the right value?
                mq[field_name] = 0
              end
            end
          end
        end
        mq.save
      end
    end

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
