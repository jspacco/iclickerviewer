def get_session(session_code, sessions)
  if !sessions.key? session_code
    s = ClassPeriod.find_by session_code: session_code
    sessions[session_code] = s
  end
  return sessions[session_code]
end

def parse(filename)
  # cache the session records and the questions
  sessions = Hash.new
  questions = Hash.new
  File.open(filename, "r").each_line do |line|
    next if line.strip == ''
    f1, f2, match = line.split
    puts "#{f1} #{f2} = #{match}"

    '''
    Files in the form: KnoxCS142W15/L1501071005_Q1.jpg
    get course title
    get L session tag
    get question number
    Look up the question to get QID
    How do we handles matches with a pair? Just match to any of them? Cannot remember.
    '''
    class1, file1 = f1.split('/')
    session_code1 = file1.split('_')[0]

    class2, file2 = f2.split('/')
    session_code2 = file2.split('_')[0]

    if match == '0'
      #
      session = get_session(session_code1, sessions)
      puts session.course_id
    elsif match == '1'

    elsif match == '2'

    end

  end
end

if __FILE__ == $0
  filename = '/Users/jspacco/projects/clickers/iclickerviewer/pictureMatch/output/KnoxCS142W15-KnoxCS142S15.txt'
  parse(filename)
end
