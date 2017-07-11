module SessionsHelper
  # include Utilities

  def correct_pct(question)
    # Compute percentage of correct responses.
    # Can use * since we are storing correct as 0 or 1.
    # TODO: multiple correct answers
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

  def question_pair_options(question, all_questions)
    result = []
    all_questions.each do |q|
      # Skip questions that are marked individual, error, or non-MCQ
      if ![1,3,4].include?(question.question_type) &&
        question.question_index != q.question_index
        result.push([q.question_index.to_s, q.question_index.to_s])
      end
    end
    return result
  end

  def selected_num(expected, actual)
    if expected.to_i == actual.to_i
      return "selected"
    else
      return ""
    end
  end

  private
  def pct_string(num, denom)
    "%s\%" % ((num.to_f / denom.to_f) * 100).round(1).to_s
  end
end
