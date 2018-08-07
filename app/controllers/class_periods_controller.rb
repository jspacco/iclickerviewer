class ClassPeriodsController < ApplicationController
  include ApplicationHelper
  # -------------------------------------------------------------
  # GET /class_periods/1
  def show
    start = current_time
    get_questions_course_class_period
    total = current_time - start
    puts "total time for class_periods#show is #{total}"

    get_keyword_hash(params[:id])

    get_question_keyword_list

    # get_match_stats(ClassPeriod.find_by(id: params[:id]))
  end

  # -------------------------------------------------------------
  # POST /class_periods/1
  def update

    # TODO Can we iterate through questions listed in parameters, not all
    #   questions from DB? One issue is how to know that something has been
    #   unchecked, if that is the only change. The current approach is a
    #   conservative approach.
    Question.where(class_period_id: params[:id]).each do |question|
      matching_question_id = params[:questions][question.id.to_s][:matching_questions]
      if matching_question_id
        match_type = params[:questions][question.id.to_s][:match_type]
        if match_type == 'identical'
          match_type = 0
        elsif match_type == 'modified'
          match_type = 1
        elsif match_type == 'modified_plus'
          match_type = 2
        else
          match_type = nil
        end
        mq = MatchingQuestion.find_or_create_by(question_id: question.id,
          matching_question_id: matching_question_id,
          match_type: match_type,
          is_match: 1)
      end

      # Edit matching questions where we set a different match_type
      to_edit = params[:questions][question.id.to_s][:edit_matching_questions]
      if to_edit
        to_edit.each do |edit_matching_question_id, match_type|
          edit_matching_question_id = Integer(edit_matching_question_id)
          match_type = Integer(match_type)

          mq = MatchingQuestion.find_by(question_id: question.id,
            matching_question_id: edit_matching_question_id)
          mq.match_type = match_type
          mq.save
        end
      end

      # Delete any matching questions that are to be deleted.
      to_delete = params[:questions][question.id.to_s][:delete_matching_questions]
      if to_delete
        to_delete.each do |delete_matching_question_id|
          # Delete in both directions, [question_id, matching_question_id]
          #   and also [matching_question_id, question_id]
          MatchingQuestion.find_by(question_id: question.id,
            matching_question_id: delete_matching_question_id).destroy
        end
      end

      changed_question_phrasing = params[:questions][question.id.to_s][:set_changed_q_p]
      if changed_question_phrasing
        changed_question_phrasing.each do |changed_question_phrasing_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_question_phrasing_id)
        mq.changed_question_phrasing = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_question_values = params[:questions][question.id.to_s][:set_changed_q_v]
      if changed_question_values
        changed_question_values.each do |changed_question_values_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_question_values_id)
        mq.changed_question_values = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_info_phrasing = params[:questions][question.id.to_s][:set_changed_i_p]
      if changed_info_phrasing
        changed_info_phrasing.each do |changed_info_phrasing_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_info_phrasing_id)
        mq.changed_info_phrasing = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_info_layout = params[:questions][question.id.to_s][:set_changed_i_l]
      if changed_info_layout
        changed_info_layout.each do |changed_info_layout_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_info_layout_id)
        mq.changed_info_layout = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_answers_phrasing = params[:questions][question.id.to_s][:set_changed_a_p]
      if changed_answers_phrasing
        changed_answers_phrasing.each do |changed_answers_phrasing_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_answers_phrasing_id)
        mq.changed_answers_phrasing = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_answers_values = params[:questions][question.id.to_s][:set_changed_a_v]
      if changed_answers_values
        changed_answers_values.each do |changed_answers_values_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_answers_values_id)
        mq.changed_answers_values = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_answers_order = params[:questions][question.id.to_s][:set_changed_a_o]
      if changed_answers_order
        changed_answers_order.each do |changed_answers_order_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_answers_order_id)
        mq.changed_answers_order = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_answers_type = params[:questions][question.id.to_s][:set_changed_a_t]
      if changed_answers_type
        changed_answers_type.each do |changed_answers_type_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_answers_type_id)
        mq.changed_answer_type = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end

      changed_other = params[:questions][question.id.to_s][:set_changed_o]
      if changed_other
        changed_other.each do |changed_other_id, changed_val|
        mq=  MatchingQuestion.find_by(question_id: question.id,
          matching_question_id: changed_other_id)
        mq.changed_other = Integer(changed_val)
        if(changed_val == 1)
          mq.match_type = 2;
        end
        mq.save
        end
      end


      #----------------------------------------------------------

      # TODO more elegant way to create self-referential many-to-many.
      # Delete the matching_questions key from params, now that we've already
      #   used it. This allows us to use update_attributes without getting
      #   an error for "Unpermitted parameter".
      params[:questions][question.id.to_s].delete(:matching_questions)

      # Handle keyword tags
      keyword_tag = params[:questions][question.id.to_s][:keywords]
      if keyword_tag != ''
        keyword = Keyword.find_or_create_by(keyword: keyword_tag)
        tag = KeywordQuestionTag.find_or_create_by(keyword: keyword,
          user_id: current_user.id.to_s,
          question: question)
      end


      params[:questions][question.id.to_s].delete(:keywords)

      # Updates the actual question
      question.update_attributes(question_params(question))
    end

    redirect_to action: :show, id: params[:id]
  end

  def update_course_hash
    # custom handler defined in routes.rb
    # get '/update_course_hash/:id', to: 'class_periods#update_course_hash'
    new_hash = get_course_hash
    new_hash = new_hash.to_json.gsub("\n", '')
    course_hash = CourseHash.find_or_create_by(id:1)
    course_hash.course_hash = new_hash
    course_hash.save
    redirect_to class_period_path params[:id]
  end

  private

  # -------------------------------------------------------------
  def get_keyword_hash(class_period_id)
    list = Question.includes(:keywords).where(class_period_id: class_period_id)
    @question_keywords = Hash.new

    list.each do |q|
      if !@question_keywords.key? q.id.to_s
        @question_keywords[q.id.to_s] = []
      end
      q.keywords.each do |keyword|
        @question_keywords[q.id.to_s] << keyword.keyword
      end
    end
  end

  # -------------------------------------------------------------
  def get_match_stats(class_period)
    @matches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 1}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@matches, q.id)
      end
    end

    @possible_matches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => nil}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@possible_matches, q.id)
      end
    end

    @nonmatches = Hash.new
    class_period.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 0}).each do |mq|
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@nonmatches, q.id)
      end
    end
  end

  # -------------------------------------------------------------
  def get_course_hash
    # This is super-slow because it recomputes everything from the DB.
    # We cache this data in the the table :course_hash
    course_hash = Hash.new
    Course.all.each do |course|
      class_period_hash = Hash.new
      ClassPeriod.where(course_id: course.id).each do |class_period|
        question_hash = Hash.new
        Question.where(class_period_id: class_period.id).each do |question|
          question_hash[question.question_index] = question.id
        end
        class_period_hash[class_period.session_code] = question_hash
      end
      course_hash[course.folder_name] = class_period_hash
    end
    return course_hash
  end

  # -------------------------------------------------------------
  def question_params(question)
    # FIXME Is setting empty strings to nil even necessary?
    if params[:questions][question.id.to_s][:question_pair] == ""
      params[:questions][question.id.to_s][:question_pair] = nil
    end

    # TODO Document require vs permit, as well as how :questions gets us the array.
    return params.require(:questions).require(question.id.to_s).permit(:correct_a,
      :correct_b, :correct_c, :correct_d, :correct_e, :question_type,
      :question_pair, :keywords)
  end

  # -------------------------------------------------------------
  def get_questions_course_class_period
    # puts "course: #{params['old_dynamic_course_selected']}"
    # puts "class: #{params['old_dynamic_class_period_selected']}"
    # puts "question: #{params['old_dynamic_question_selected']}"
    # puts "has key? #{params.has_key?('old_dynamic_course_selected')}"
    @old_dynamic_course_selected = ''
    if params.has_key?('old_dynamic_course_selected')
      @old_dynamic_course_selected = params['old_dynamic_course_selected']
    end
    @old_dynamic_class_period_selected = ''
    if params.has_key?('old_dynamic_class_period_selected')
      @old_dynamic_class_period_selected = params['old_dynamic_class_period_selected']
    end
    old_dynamic_question_selected = ''
    if params.has_key?('old_dynamic_question_selected')
      @old_dynamic_question_selected = params['old_dynamic_question_selected']
    end
    # puts "ivar course: #{@old_dynamic_course_selected}"
    # puts "ivar class: #{@old_dynamic_class_period_selected}"
    # puts "ivar ques: #{@old_dynamic_question_selected}"
    # Look up the class period, course, and questions
    @class_period = ClassPeriod.find_by(id: params[:id])
    # For making a link to the next class.
    # TODO CACHE should we cache this? probably not worth it.
    @next_class_period = ClassPeriod.where("session_code > ? and course_id = ?",
      @class_period.session_code, @class_period.course_id).first
    @course = Course.find_by(id: @class_period.course_id)
    @questions = Question.where(class_period_id: @class_period.id).order(:question_index)
    # Look up a hash from course_name => session_code (class_period) => question_index => question_id

    #TODO can this work? Issue is we have to call it for each question but it's good form to keep db queries out of the view right?
    #@matching_questions = MatchingQuestion.where(question_id: q.object.id, :is_match => 1)



    start_hash = current_time
    if CourseHash.first != nil
      # read cached version, if it exists
      @course_hash = CourseHash.first.course_hash
    else
      # otherwise, recompute the course_hash from the DB
      @course_hash = get_course_hash
    end
    total_hash = current_time - start_hash
    puts "@course_hash time is #{total_hash}"

    # Average time taken per clicker question
    total_time = 0.0
    num_questions = 0.0
    @questions.each do |q|
      total_time += q.num_seconds
      num_questions += 1
    end
    @avg_time = (total_time / num_questions).round(0)

  end

  # --------------------------------------------------------------------
  def get_question_keyword_list
    @keywords = []
    Keyword.all.each do |keyword|
      @keywords << keyword.keyword.downcase
    end
  end
end
