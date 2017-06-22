module SessionsHelper
  include Utilities
  def correct_pct(question)
    # Compute percentage of correct responses
    total_correct = 0
    total_correct += question.response_a * question.correct_a
    total_correct += question.response_b * question.correct_b
    total_correct += question.response_c * question.correct_c
    total_correct += question.response_d * question.correct_d
    total_correct += question.response_e * question.correct_e
    total_responses = question.response_a + question.response_b +
      question.response_c + question.response_d + question.response_e
    return pct_string(total_correct, total_responses)
  end
  def selected_num(expected, actual)
    if expected.to_i == actual.to_i
      return "selected"
    else
      return ""
    end
  end
end
