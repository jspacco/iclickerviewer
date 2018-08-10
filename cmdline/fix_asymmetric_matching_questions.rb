#ActiveRecord::Base.logger.level = 1
old_logger = ActiveRecord::Base.logger
ActiveRecord::Base.logger = nil

count = 0
MatchingQuestion.where(is_match: 1).each do |mq|
  MatchingQuestion.where(question_id: mq.matching_question_id, matching_question_id: mq.question_id, is_match: nil).each do |mq2|
    mq2.is_match = mq.is_match
    mq2.match_type = mq.match_type
    mq2.save
    count += 1
  end
end

puts "Updates #{count} records"
