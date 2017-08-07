require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test "course joins questions through class periods" do
    course = Course.find_by(name: 'test_class1')

    # create set of all class periods for this course without using a join
    class_periods = Set.new
    ClassPeriod.where(course: course).each do |cp|
      class_periods << cp.id
    end

    # Now make sure we get all of the questions for this class
    questions = course.questions
    questions.each do |q|
      assert class_periods.include? q.class_period_id
    end

  end
end
