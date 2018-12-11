def get_session(session_code, classname, sessions)
  if !sessions.key? session_code
    c = Course.find_by(folder_name: classname)
    s = ClassPeriod.find_by(session_code: session_code, course_id: c.id)
    sessions[session_code] = s
  end
  return sessions[session_code]
end

def get_question_and_pair(classname, session_code, question_index, sessions, questions)
  question_index = question_index.to_i
  session = get_session(session_code, classname, sessions)
  if !questions.key? session_code
    questions[session_code] = Hash.new
    found = false
    Question.where(class_period_id: session.id).each do |q|
      # hash from session_code (i.e. L1609011005) to a hash from
      # question_index (i.e. question number within a class period)
      # to the question itself
      questions[session_code][q.question_index] = q
    end
  end
  question = questions[session_code][question_index]
  pair = nil
  if question.question_pair != nil
    pair = questions[session_code][question.question_pair]
  end
  question, pair = pair, question if pair != nil && question.question_index > pair.question_index
  return question, pair
end

def get_facts(filecode)
  m = /(.*)\/(.*)_Q(\d+)\.(jpg|png)/.match(filecode)
  # classname, session_code, question_number
  return m[1], m[2], m[3]
end

def parse(filename)
  # cache the session records and the questions
  sessions = Hash.new
  questions = Hash.new
  num_added = 0
  File.open(filename, "r").each_line do |line|
    next if line.strip == ''
    f1, f2, match_type = line.split
    # puts "#{f1} #{f2} = #{match_type}"
    '''
    Files in the form:
    KnoxCS142W15/L1501071005_Q1.jpg
    '''
    # classname, session_code, question_number
    class1, session_code1, question_num1 = get_facts(f1)
    class2, session_code2, question_num2 = get_facts(f2)
    q1, q1p = get_question_and_pair(class1, session_code1, question_num1, sessions, questions)
    q2, q2p = get_question_and_pair(class2, session_code2, question_num2, sessions, questions)
    # get the pair of q2 if one exists

    # 4 possible ways to match:
    # q1 to q2
    # q1p to q2
    # q1 to q2p
    # q1p to q2p
    match1 = MatchingQuestion.find_by(question_id: q1.id, matching_question_id: q2.id)
    match2 = match3 = match4 = nil
    if q1p != nil
      match2 = MatchingQuestion.find_by(question_id: q1p.id, matching_question_id: q2.id)
    end
    if q2p != nil
      match3 = MatchingQuestion.find_by(question_id: q1.id, matching_question_id: q2p.id)
    end
    if q1p != nil && q2p != nil
      match4 = MatchingQuestion.find_by(question_id: q1p.id, matching_question_id: q2p.id)
    end

    if match_type == '0' || match_type == '1'
      # near exact match, so put into the DB as a potential match
      if match1 == nil && match2 == nil && match3 == nil && match4 == nil
        puts "create record for #{f1} #{f2}"
        mq = MatchingQuestion.find_or_create_by(question_id: q1.id,
          matching_question_id: q2.id,
          # nil match_type means a possible match
          match_type: nil,
          # is_match nil means we are not sure if it's a match
          is_match: nil)
        puts "created mq.id = #{mq.id} from #{}{q1.id} to #{q2.id}"
        num_added += 1
      else
        puts "already have a record for #{f1} and #{f2}"
      end
    elsif match_type == '2'
      # not sure what to do with this?
      puts "possible match between #{f1} #{f2}"
    end
  end
  puts "added a total of #{num_added} possible match records"
end

if __FILE__ == $0
  filename = '/Users/jspacco/projects/clickers/iclickerviewer/pictureMatch/output/KnoxCS142W15-KnoxCS142S15.txt'
  parse(filename)
end
