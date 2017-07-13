class CoursesController < ApplicationController
  def index
    dburl = ENV['DATABASE_URL']
    puts "WHERE IS THE GODDAM DB URL: #{dburl}"
    @courses = Course.all
    # TODO avg number of CQs over all classes,
    #   avg time per CQ,
    #   pairing/individual stats???
    @all_class_stats = Hash.new
    @courses.each do |course|
      @all_class_stats[course.id] = get_class_stats(course.id)
    end
  end

  def show
    @course = Course.find(params[:id])
    # TODO sort sessions by date
    # Using classes instead of sessions because "session" means other things
    #   for a web service.
    @classes = Session.where(course_id: @course.id)
    @class_stats = get_class_stats(@course, @classes)
    @each_class_stats = Hash.new
    @classes.each do |sess|
      class_hash = Hash.new
      class_hash[:num_questions] = Question.where(session_id: sess.id).length
      class_hash[:avg_time] = Question.where(session_id: sess.id).sum(:num_seconds).to_f / class_hash[:num_questions]
      @each_class_stats[sess.id] = class_hash
    end
  end

  private

  def get_class_stats(course_id, classes=nil)
    if classes == nil
      classes = Session.where(course_id: course_id)
    end
    class_stats = Hash.new
    total_time = 0.0
    num_questions = 0.0
    classes.each do |sess|
      questions = Question.where(session_id: sess)
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
end
