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

Course.all.each do |course|
  # puts course.id
  total_time_course = 0.0
  total_questions_course = 0.0
  num_classes_updated = 0
  total_classes = 0
  classes = ClassPeriod.where(course_id: course.id)
  classes.each do |class_period|
    total_time_class_period = 0.0
    num_questions_updated = 0
    total_questions_class_period = 0
    questions = Question.where(class_period_id: class_period.id)
    questions.each do |question|
      if data_entered?(question)
        num_questions_updated += 1
      end
      total_questions_course += 1
      total_questions_class_period += 1
      total_time_course += question.num_seconds
      total_time_class_period += question.num_seconds
    end
    if num_questions_updated == total_questions_class_period
      num_classes_updated += 1
    end
    total_classes += 1

    class_period_cache = ClassPeriodCache.find_or_create_by(id: class_period.id)
    class_period_cache.course_id = course.id
    class_period_cache.session_code = class_period.session_code
    class_period_cache.num_questions = total_questions_class_period
    class_period_cache.avg_secs_question = total_time_class_period / total_questions_class_period
    class_period_cache.num_questions_updated = num_questions_updated
    class_period_cache.total_class_periods = questions.length
    class_period_cache.save
  end
  course_cache = CourseCache.find_or_create_by(id: course.id)
  course_cache.avg_questions_class = total_questions_course / classes.length
  course_cache.avg_secs_question = total_time_course / total_questions_course
  course_cache.num_classes_updated = num_classes_updated
  course_cache.total_classes = total_classes
  course_cache.save
end
