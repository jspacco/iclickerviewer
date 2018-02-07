class CoursesController < ApplicationController
  include ApplicationHelper
  def index
    @courses = Course.all.order(:folder_name)
    # TODO avg number of CQs over all classes,
    #   avg time per CQ,
    #   pairing/individual stats???
    start = current_time
    @all_class_stats = Hash.new
    @courses.each do |course|
      @all_class_stats[course.id] = get_class_stats(course.id)
    end
    get_updated_stats
    get_match_stats_all_courses
    total = current_time - start
    puts "Total time for DB crap is #{total} seconds"
  end

  def show
    @course = Course.find(params[:id])
    # TODO sort class periods by date
    @classes = ClassPeriod.where(course_id: @course.id).order(:session_code)

    start = current_time

    @class_stats = get_class_stats(@course, @classes)
    @each_class_stats = Hash.new
    @classes.each do |sess|
      class_hash = Hash.new
      class_hash[:num_questions] = Question.where(class_period_id: sess.id).length
      class_hash[:avg_time] = Question.where(class_period_id: sess.id).sum(:num_seconds).to_f / class_hash[:num_questions]
      @each_class_stats[sess.id] = class_hash
    end
    get_updated_stats
    get_match_stats(@course)
    total = current_time - start
    puts "Time for show DB crap #{total}"
  end

  private

  def current_time
    return Time.now.to_f
  end

  def get_class_stats(course_id, classes=nil)
    if classes == nil
      classes = ClassPeriod.where(course_id: course_id)
    end
    class_stats = Hash.new
    total_time = 0.0
    num_questions = 0.0
    classes.each do |sess|
      questions = Question.where(class_period_id: sess)
      questions.each do |question|
        total_time += question.num_seconds
      end
      num_questions += questions.length
      # Create hash of stats
    end
    class_stats[:avg_time] = total_time / num_questions
    class_stats[:avg_num_questions] = num_questions / classes.length
    return class_stats
  end

  def get_updated_stats
    # course_id => [updated, total] for each class overall
    @question_updated_counts = Hash.new
    # session_code => [updated, total] for each class period
    @class_period_updated_counts = Hash.new
    Course.all.each do |course|
      classes_updated = 0
      classes_total = 0
      ClassPeriod.where(course_id: course.id).each do |class_period|
        updated = 0
        total = 0
        Question.where(class_period_id: class_period.id).each do |question|
          if data_entered?(question)
            updated += 1
          end
          total += 1
        end
        @question_updated_counts[class_period.session_code] = [total - updated, total]
        if updated == total
          classes_updated += 1
        end
        classes_total += 1
      end
      @class_period_updated_counts[course.id] = [classes_total - classes_updated, classes_total]
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
end
