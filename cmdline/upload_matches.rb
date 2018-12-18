def get_session(session_code, classname, sessions)
  if !sessions.key? session_code
    c = Course.find_by(folder_name: classname)
    if c == nil
      puts "cannot find #{classname}"
    end
    s = ClassPeriod.find_by(session_code: session_code, course_id: c.id)
    sessions[session_code] = s
  end
  return sessions[session_code]
end

def get_question_and_pair(classname, session_code, question_index, sessions, questions)
  question_index = question_index.to_i
  session = get_session(session_code, classname, sessions)
  if session == nil
    puts "Cannot find session #{session_code} for classname #{classname}. This should not happen!"
    puts "Check the XML file #{classname}/SessionData/#{session_code}.xml and try to figure out what happened."
    return nil, nil
  end
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
  if question == nil
    return nil, nil
  end
  pair = nil
  if question.question_pair != nil
    pair = questions[session_code][question.question_pair]
  end
  question, pair = pair, question if pair != nil && question.question_index > pair.question_index
  return question, pair
end

def get_facts(filecode)
  m = /(.*)\/(.*)_Q(\d+)\.(jpg|png)/.match(filecode)
  if m == nil
    return nil, nil, nil
  end
  # classname, session_code, question_number
  return m[1], m[2], m[3]
end

def parse(filename)
  # cache the session records and the questions
  sessions = Hash.new
  questions = Hash.new
  num_added = 0
  errors = 0
  existing = 0
  File.open(filename, "r").each_line do |line|
    next if line.strip == ''
    f1, f2, match_type = line.split
    # puts "#{f1} #{f2} = #{match_type}"
    '''
    Files in the form:
    KnoxCS142W15/L1501071005_Q1.jpg

    We may have images that look like this:
    KnoxCS142W15/L1501071005_Q3(1).jpg
    These might match things, but these do not have entries
    in the XML/CSV files, so we will never find the images.
    '''
    # classname, session_code, question_number
    class1, session_code1, question_num1 = get_facts(f1)
    class2, session_code2, question_num2 = get_facts(f2)
    if class1 == nil
      puts "Extra image file: #{f1}"
      next
    end
    if class2 == nil
      puts "Extra image file: #{f1}"
      next
    end
    q1, q1p = get_question_and_pair(class1, session_code1, question_num1, sessions, questions)
    q2, q2p = get_question_and_pair(class2, session_code2, question_num2, sessions, questions)
    # check if we got back nil
    # this can happen because sometimes the clicker system grabs images that
    # don't show up in in the XML/CSV data files
    if q1 == nil
      puts "cannot find #{session_code1}-#{question_num1}"
      errors += 1
      next
    end
    if q2 == nil
      puts "cannot find #{session_code2}-#{question_num2}"
      errors += 1
      next
    end
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
        # puts "create record for #{f1} #{f2}"
        mq = MatchingQuestion.find_or_create_by(question_id: q1.id,
          matching_question_id: q2.id,
          # nil match_type means a possible match
          match_type: nil,
          # is_match nil means we are not sure if it's a match
          is_match: nil)
        # puts "created mq.id = #{mq.id} from #{q1.id} to #{q2.id}"
        num_added += 1
      else
        # puts "already have a record for #{f1} and #{f2}"
        existing += 1
      end
    elsif match_type == '2'
      # not sure what to do with this?
      # puts "possible match between #{f1} #{f2}"
    end
  end
  puts "#{File.basename(filename, ".*")}: added #{num_added} records, #{existing} already there, with #{errors} errors"
end

if __FILE__ == $0
  path = '/Users/jspacco/projects/clickers/iclickerviewer/pictureMatch/output'
  cs142 = ['KnoxCS142W15-KnoxCS142S15.txt',
    'KnoxCS142S15-KnoxCS142W16.txt',
    'KnoxCS142W16-KnoxCS142S16.txt',
    'KnoxCS142S16-KnoxCS142W17.txt',
    'KnoxCS142W17-KnoxCS142S17.txt']
  cs141 = ['KnoxCS141F15-1-KnoxCS141F15-2.txt',
    'KnoxCS141F15-2-KnoxCS141W16.txt',
    'KnoxCS141F16-1-KnoxCS141F16-2.txt',
    'KnoxCS141F16-2-KnoxCS141W17-2.txt',
    'KnoxCS141W15-KnoxCS141F15-1.txt',
    'KnoxCS141W16-KnoxCS141F16-1.txt']
  cse141 = ['UCSD.CSE141F14-A-UCSD.CSE141F14-B.txt',
    'UCSD.CSE141F14-B-UCSD.CSE141F15.txt',
    'UCSD.CSE141F15-UCSD.CSE141F16.txt',
    'UCSD.CSE141F16-UCSD.CSE141S17-1.txt',
    'UCSD.CSE141S17-1-UCSD.CSE141S17-2.txt']

  for f in cse141
    fullpath = path + '/' + f
    parse(fullpath)
  end

end
