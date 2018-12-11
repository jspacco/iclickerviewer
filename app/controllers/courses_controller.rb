class CoursesController < ApplicationController
  include ApplicationHelper
  def index
    # order courses by:
    # school, course, year, term
    # (sorting by descending order is a hack because winter, spring, fall
    # sort correctly in reverse order)
    @courses = Course.all.order(:institution, :name, :year, term: :desc)

    start = current_time

    get_all_class_stats

    # Hash mapping course_id to number of possible matched questions
    # that need to be processed
    results = ActiveRecord::Base.connection.exec_query(sqlmatchcourse)
    @course_match_hash = Hash.new
    results.each do |row|
      @course_match_hash[row['course_id']] = row['count']
    end

    total = current_time - start
    puts "get_all_class_stats is #{total} seconds"

    start = current_time

    get_updated_stats

    total = current_time - start
    puts "get_updated_stats is #{total} seconds"


    get_match_stats_all_courses


  end

  def show
    @course = Course.find(params[:id])
    # TODO sort class periods by date
    @classes = ClassPeriod.where(course_id: @course.id).order(:session_code)

    # Look up using SQL aggregation (which I can't figure out how to do
    # with ActiveRecord) session_code mapped to number of potential matches
    # for this course
    results = ActiveRecord::Base.connection.exec_query(sqlmatch(@course.id))
    @session_code_hash = Hash.new
    results.each do |row|
      @session_code_hash[row['session_code']] = row['count']
    end

    update_start = current_time
    get_updated_stats
    update_total = current_time - update_start
    puts "Time for courses#show updated stats is #{update_total}"

  end

  private

  def get_all_class_stats
    @all_class_stats = Hash.new
    CourseCache.all.each do |course_cache|
      course_stats = Hash.new
      course_stats[:avg_time] = course_cache.avg_secs_question
      course_stats[:avg_num_questions] = course_cache.avg_questions_class
      @all_class_stats[course_cache.id] = course_stats
    end
  end

  def get_class_stats(course_id)
    # create a hash from course_id => aggregate course stats
    # aggregate course stats are avg time per question, avg questions per class,
    #
    # Uses cached data to save time
    # Caching data breaks the normalized form of the DB, but
    # the app was much too slow otherwise
    @course_stats = Hash.new
    course_cache = CourseCache.find_by(id: course_id)
    if course_cache != nil
      @course_stats[:avg_time] = course_cache.avg_secs_question
      @course_stats[:avg_num_questions] = course_cache.avg_questions_class
    end
  end

  def get_updated_stats
    # Uses cached information to save time
    @question_updated_counts = Hash.new
    # session_code => [updated, total] for each class period
    @class_period_updated_counts = Hash.new
    ClassPeriodCache.all.each do |class_period_cache|
      # TODO fix with real names of things
      @question_updated_counts[class_period_cache.session_code] = [class_period_cache.num_questions_updated, class_period_cache.num_questions]
      course_cache = CourseCache.find_by(id: class_period_cache.course_id)
      @class_period_updated_counts[class_period_cache.course_id] = [course_cache.num_classes_updated, course_cache.total_classes]
    end
  end

  def get_match_stats_all_courses
    # TODO Figure out how to query matched_questions and the mathing_questions
    #   join table at the same time and use an if to check is_match
    @num_possible_matches = Hash.new
    @num_matches = Hash.new
    @num_nonmatches = Hash.new
    # FIXME This is way too slow! Fix it.
    # Course.all.each do |course|
    #   course.questions.each do |q|
    #     q.matched_questions.where(:matching_questions => {:is_match => nil}).each do |mq|
    #       next if q.id == mq.id or q.class_period_id == mq.class_period_id
    #       increment(@num_possible_matches, course.id)
    #     end
    #     q.matched_questions.where(:matching_questions => {:is_match => 1}).each do |mq|
    #       next if q.id == mq.id or q.class_period_id == mq.class_period_id
    #       increment(@num_matches, course.id)
    #     end
    #     q.matched_questions.where(:matching_questions => {:is_match => 0}).each do |mq|
    #       next if q.id == mq.id or q.class_period_id == mq.class_period_id
    #       increment(@num_nonmatches, course.id)
    #     end
    #   end
    # end
  end

  def get_match_stats(course)
    # TODO make this properly use active record joins
    @num_possible_matches = Hash.new

    course.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => nil}).each do |mq|
        # TODO move this check into a callback for the matched_questions relation
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@num_possible_matches, q.class_period_id)
        # @num_possible_matches += 1
      end
    end

    @num_matches = Hash.new
    course.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 1}).each do |mq|
        # TODO move this check into a callback for the matched_questions relation
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@num_matches, q.class_period_id)
      end
    end

    @num_nonmatches = Hash.new
    course.questions.each do |q|
      q.matched_questions.where(:matching_questions => {:is_match => 0}).each do |mq|
        # TODO move this check into a callback for the matched_questions relation
        next if q.id == mq.id or q.class_period_id == mq.class_period_id
        increment(@num_nonmatches, q.class_period_id)
      end
    end
  end

  def sqlmatch(course_id)
    return """
SELECT cp.session_code as session_code, count(*) as count
  FROM class_periods cp, questions q, matching_questions mq
  WHERE cp.course_id = #{course_id}
  AND q.class_period_id = cp.id
  AND mq.question_id = q.id
  AND mq.is_match is NULL
  AND mq.match_type is NULL
  GROUP BY cp.session_code
"""
  end

  def sqlmatchcourse
    return """
SELECT cp.course_id as course_id, count(*) as count
  FROM matching_questions mq, questions q, class_periods cp
  WHERE (mq.match_type is NULL OR mq.is_match is NULL)
  AND mq.question_id = q.id
  AND q.class_period_id = cp.id
  GROUP BY cp.course_id
"""
  end
end
