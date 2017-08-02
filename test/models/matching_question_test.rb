require 'test_helper'

class MatchingQuestionTest < ActiveSupport::TestCase
  def mirror?(m1, m2)
    assert m1.question_id == m2.matching_question_id and
      m1.matching_question_id == m2.question_id
    # puts "m1.match_type #{m1.match_type}, m2.match_type #{m2.match_type}"
    assert m1.match_type == m2.match_type
    # puts "m1.is_match #{m1.is_match} m2.is_match #{m2.is_match}"
    assert m1.is_match == m2.is_match
  end

  # TODO: matches should not work for pairs (validation?)

  test "create match between questions" do
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    class_period2 = ClassPeriod.find_by(session_code: 'class_period2')

    q1 = Question.find_by(class_period: class_period1, question_index: 1)
    q2 = Question.find_by(class_period: class_period2, question_index: 1)

    # match Queston 1 from class_period1 to Question 1 from class_period2,
    #   where class_period2 is from a different course
    m = MatchingQuestion.new(question: q1, matching_question: q2)
    assert m.save

    # ensure symmatrical matches in the DB
    assert MatchingQuestion.find_by(question_id: q1.id) != nil
    assert MatchingQuestion.find_by(matching_question_id: q1.id) != nil
    assert MatchingQuestion.find_by(question_id: q2.id) != nil
    assert MatchingQuestion.find_by(matching_question_id: q2.id) != nil

    # sanity check: make sure that question works like question_id, and
    #   matching_question works like matching_question_id
    assert MatchingQuestion.find_by(question: q1) != nil
    assert MatchingQuestion.find_by(matching_question: q1) != nil
    assert MatchingQuestion.find_by(question: q2) != nil
    assert MatchingQuestion.find_by(matching_question: q2) != nil
  end

  test "update match between questions" do
    # match Question 1 from class_period1 (which is paired with Question 2)
    #   with Question 1 from class_period2 (which is paired with Question 2)
    # check that a cascade happens
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    class_period2 = ClassPeriod.find_by(session_code: 'class_period2')

    q1 = Question.find_by(class_period: class_period1, question_index: 1)
    q2 = Question.find_by(class_period: class_period2, question_index: 1)

    m1 = MatchingQuestion.new(question: q1, matching_question: q2)
    assert m1.save

    # Did matching q1 and q2 create a 2nd entry in matching_questions?
    m2 = MatchingQuestion.find_by(question: q2, matching_question: q1)
    assert m2 != nil
    mirror?(m1, m2)

    # Now update m1!
    m1.match_type = 1
    m1.is_match = 1
    m1.save

    # Did updating m1 trigger an update of m2?
    # Note that we need to look up m2 again because ActiveRecord won't magically
    #   update existing instances.
    m2 = MatchingQuestion.find_by(question: q2, matching_question: q1)
    assert m2 != nil
    mirror?(m1, m2)
  end

  test "delete match between questions" do
    # match Question 1 from class_period1 (which is paired with Question 2)
    #   with Question 1 from class_period2 (which is paired with Question 2)
    # check that a cascade happens
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    class_period2 = ClassPeriod.find_by(session_code: 'class_period2')

    q1 = Question.find_by(class_period: class_period1, question_index: 1)
    q2 = Question.find_by(class_period: class_period2, question_index: 1)

    m1 = MatchingQuestion.new(question: q1, matching_question: q2)
    assert m1.save

    # Ensure matching q1 and q2 creates a 2nd entry in matching_questions
    # (should work because this is tested above)
    m2 = MatchingQuestion.find_by(question: q2, matching_question: q1)
    assert m2 != nil
    mirror?(m1, m2)

    # make sure that deleting m1 deletes both m1 and m2
    m1.destroy
    assert MatchingQuestion.where(question: q1, matching_question: q2).length == 0
    assert MatchingQuestion.where(question: q2, matching_question: q1).length == 0

  end
end
