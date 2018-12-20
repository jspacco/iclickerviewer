class ClassPeriodsController < ApplicationController
  include ApplicationHelper
  # -------------------------------------------------------------
  # GET /class_periods/1
  def show
    start = current_time

    get_questions_course_class_period
    total = current_time - start

    # TODO do this with ActiveRecord
    results = ActiveRecord::Base.connection.exec_query(sqlmatchgroup)
    @question_hash = Hash.new
    results.each do |row|
      @question_hash[row['question_id']] = row['count']
    end

    get_keyword_hash(params[:id])

    get_question_keyword_list

    puts "total time for class_periods#show is #{total}"

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
        # TODO refactor if possible
        set_q_p = params[:questions][question.id.to_s][:set_q_p] == '1' ? 1 : 0
        set_q_v = params[:questions][question.id.to_s][:set_q_v] == '1' ? 1 : 0
        set_i_p = params[:questions][question.id.to_s][:set_i_p] == '1' ? 1 : 0
        set_i_l = params[:questions][question.id.to_s][:set_i_l] == '1' ? 1 : 0
        set_i_a = params[:questions][question.id.to_s][:set_i_a] == '1' ? 1 : 0
        set_a_p = params[:questions][question.id.to_s][:set_a_p] == '1' ? 1 : 0
        set_a_v = params[:questions][question.id.to_s][:set_a_v] == '1' ? 1 : 0
        set_a_o = params[:questions][question.id.to_s][:set_a_o] == '1' ? 1 : 0
        set_a_t = params[:questions][question.id.to_s][:set_a_t] == '1' ? 1 : 0
        set_s_p = params[:questions][question.id.to_s][:set_s_p] == '1' ? 1 : 0
        set_o = params[:questions][question.id.to_s][:set_o] ==     '1' ? 1 : 0

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
          changed_question_phrasing: set_q_p,
          changed_question_values: set_q_v,
          changed_info_phrasing: set_i_p,
          changed_info_layout: set_i_l,
          changed_info_added: set_i_a,
          changed_answers_phrasing: set_a_p,
          changed_answers_values: set_a_v,
          changed_answers_order: set_a_o,
          changed_slide_presentation: set_s_p,
          changed_other: set_o,
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

          # XXX The HTML parameters are not the cleanest or most intuitive
          # way to express changes to modified+, but this all works perfectly!
=begin
"questions": {
      "8635": {
         "question_type": "2",
         "question_pair": "",
         "correct_a": "0",
         "correct_b": "0",
         "correct_c": "0",
         "correct_d": "1",
         "correct_e": "0",
         "keywords": "",
         "edit_matching_questions": {
            "11": "2",
            "22": "2"
         },
         "set_changed_q_p": {
            "11": "1",
            "22": "0"
         },
         "set_changed_q_v": {
            "11": "0",
            "22": "0"
         },
         "matching_questions": ""
      },
      etc.
=end
          if match_type == 2
            # check for changes to modified+ expanded match categories
            get_modified_plus_category_hash.each do |field_name, field_code|
              changed_field = params[:questions][question.id.to_s]["set_changed_#{field_code}"]
              if changed_field
                puts changed_field
                changed_field.each do |id, changed_val|
                  mq = MatchingQuestion.find_by(question_id: question.id,
                    matching_question_id: id)
                  mq[field_name] = Integer(changed_val)
                  if(changed_val == 1)
                    mq.match_type = 2;
                  end
                  mq.save
                end
              end
            end
          end
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

    # Update cache stats for this course
    start = current_time
    update_class_period_cache(ClassPeriod.find_by(id: params[:id]))
    total = current_time - start
    puts "total time to update class_period_cache: #{total}"

    # use quick preview parameters
    if params[:old_dynamic_course_selected]
      redirect_to action: :show, id: params[:id],
        old_dynamic_course_selected: params[:old_dynamic_course_selected],
        old_dynamic_class_period_selected: params[:old_dynamic_class_period_selected],
        old_dynamic_question_selected: params[:old_dynamic_question_selected]
    else
      redirect_to action: :show, id: params[:id]
    end
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

  # -------------------------------------------------------------
  # private helper methods
  # -------------------------------------------------------------
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
  # XXX We aren't calling this method anymore because it's too slow!
  # This code is now in match_controller.rb
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
      @class_period.session_code, @class_period.course_id).order(:session_code).first
    @prev_class_period = ClassPeriod.where("session_code < ? and course_id = ?",
      @class_period.session_code, @class_period.course_id).order(:session_code).last
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

  # --------------------------------------------------------------------
  # Update the course_cache and class_period_cache,
  # but only for the course for this class_period.
  # --------------------------------------------------------------------
  def update_class_period_cache(class_period)
    total_time_course = 0.0
    total_questions_course = 0.0
    num_classes_updated = 0
    total_classes = 0
    classes = ClassPeriod.where(course_id: class_period.course_id)
    classes.each do |class_period|
      total_time_class_period = 0.0
      num_questions_updated = 0
      total_questions_class_period = 0
      questions = Question.where(class_period_id: class_period.id)
      questions.each do |question|
        if data_entered?(question)
          num_questions_updated += 1
        end
        total_questions_course += 1
        total_questions_class_period += 1
        total_time_course += question.num_seconds
        total_time_class_period += question.num_seconds
      end
      if num_questions_updated == total_questions_class_period
        num_classes_updated += 1
      end
      total_classes += 1

      class_period_cache = ClassPeriodCache.find_or_create_by(id: class_period.id)
      class_period_cache.course_id = class_period.course_id
      class_period_cache.session_code = class_period.session_code
      class_period_cache.num_questions = total_questions_class_period
      class_period_cache.avg_secs_question = total_time_class_period / total_questions_class_period
      class_period_cache.num_questions_updated = num_questions_updated
      class_period_cache.total_class_periods = questions.length
      class_period_cache.save
    end
    course_cache = CourseCache.find_or_create_by(id: class_period.course_id)
    course_cache.avg_questions_class = total_questions_course / classes.length
    course_cache.avg_secs_question = total_time_course / total_questions_course
    course_cache.num_classes_updated = num_classes_updated
    course_cache.total_classes = total_classes
    course_cache.save
  end

  def sqlmatchgroup
    # TODO fix this, looks like a cross join!
    return """
SELECT mq.question_id as question_id, count(*) as count
  FROM matching_questions mq, questions q
  WHERE mq.match_type is NULL
  AND mq.is_match is NULL
  GROUP BY mq.question_id
"""
  end
end
