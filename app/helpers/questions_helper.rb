module QuestionsHelper
  def pair_type(question)
    if question == nil
      return ''
    end
    case question.question_type
    when ''
      ''
    when nil
      ''
    when 0
      'unknown'
    when 1
      'quiz'
    when 2
      'single'
    when 3
      'paired'
    when 4
      'non-MCQ'
    when 5
      'error'
    else
      ''
    end
  end
end
