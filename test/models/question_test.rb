require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  test "create question" do
    # class_period1 is defined in test/fixtures/class_periods.yml
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    q = Question.new(name: 'Question 4',
      response_a: 100, response_b: 1, response_c: 2, response_d: 3,response_e: 5,
      correct_a: 1, correct_b: 0, correct_c: 0, correct_d: 0, correct_e: 0,
      start: '09:21:00', stop: '09:22:05', num_seconds: 65, question_index: 4,
      is_deleted: 'N',
      class_period: class_period1)
    assert q.save
    # puts "q.question_type = '#{q.question_type}', q.question_pair = '#{q.question_pair}'"
    # TODO question_type should probably default to 0, not nil
    assert q.question_type == nil
    assert q.question_pair == nil
  end

  test "find paired questions" do
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    assert class_period1.session_code == 'class_period1'
    class_period2 = ClassPeriod.find_by(session_code: 'class_period2')
    assert class_period2.session_code == 'class_period2'

    q1 = Question.find_by(class_period: class_period1, question_index: 1)
    assert q1.question_type == 3
    assert q1.question_pair == 2

    q2 = Question.find_by(class_period: class_period1, question_index: 2)
    assert q2.question_type == 3
    assert q2.question_pair == 1

  end
end
