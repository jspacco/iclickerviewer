module ApplicationHelper
  def checked?(val)
    # Helper method to decide if a checkbox should be checked based on its DB value
    if val == '1' || val == 1 || val == true
      return true
    end
    return false
  end

  def data_entered?(question)
    if [4, 5].include?(question.question_type)
      return true
    end
    if [1, 2, 3].include?(question.question_type)
      return question.correct_a + question.correct_b + question.correct_c +
      question.correct_d + question.correct_e != 0
    end
    return false
  end

=begin
Given a list of two values, return them as a string representation
of a fraction. For example, [3, 10] would be "3 / 10"
=end
  def to_s_fraction(values)
    return "#{values[0]} / #{values[1]}"
  end
end
