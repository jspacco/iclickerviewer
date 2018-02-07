require 'CSV'
require 'Logger'
# Set up a logger for command-line logging.
$logger = Logger.new(STDOUT)
# TODO set logger level from command line
$logger.level = :info
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'


def get_datetime(filename)
  # L1609120921.xml
  # L == class_period
  # 16 == 2016
  # 0912 == September 12
  # 0921 == 9:21am
  file = File.basename(filename, '.csv')
  puts file
  m = file.match(/L(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/)
  year, month, day, hour, minute = m.captures
  return DateTime.new(2000 + year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
end

def get_seconds(time)
  m = time.match(/(\d\d):(\d\d):(\d\d)/)
  hours, minutes, seconds = m.captures
  return hours.to_i * 3600 + minutes.to_i * 60 + seconds.to_i
end

def parse_CSV (filename, course, save_votes, ignore=Array.new)
  toZip = []
  times = []
  datetime = get_datetime(filename)
  session_code = File.basename(filename, '.csv')
  csv = CSV.new(open(filename), :quote_char=> "\x00")
  class_period = ClassPeriod.find_by(session_code: session_code)
  if (open(filename).readlines.size == 0)
    return
  end
  csv.each do |row|
    if row[0].include?("Scoring")
      min_response = row[3]
      participation = row[2]
      performance = row[1]
      name = 'Session 1'
      if class_period == nil
        class_period = ClassPeriod.find_or_create_by(session_code: session_code,
          name: name, date: datetime, min_response: min_response,
          participation: participation, performance: performance,
          #min_response_string: min_response_string,
          course: course)
        end
      end

      if row[0].include?("Time")
        temptime = row.drop(3)
        times.push(temptime)
      elsif row[0].include?('#')
        name = row[0]
        qs=row.drop(3)
        toZip.push(qs)
      end
    end
    puts class_period.id
    times =  times.transpose.keep_if {|v| v[0].to_s.length>2}

    timestot = times.map {|a| get_seconds(a[1])-get_seconds(a[0])}


    toZip = toZip.transpose
    x = toZip.length/6-1
    for i in 0..x
      question_name = "Problem #{i+1}"
      start= times[i][0]
      stop = times[i][1]
      is_deleted = nil
      num_seconds= timestot[i]
      question_index = i+1
      endresponses = toZip[i*6]
      response_a=endresponses.count('A')
      response_b=endresponses.count('B')
      response_c=endresponses.count('C')
      response_d=endresponses.count('D')
      response_e=endresponses.count('E')

      correct_a=0
      correct_b=0
      correct_c=0
      correct_d=0
      correct_e=0



      score = toZip[i*6+1]
      final_response_times= toZip[i*6+2]
      numAttempts = toZip[i*6+3]
      firstResponse = toZip[i*6+4]
      initialResponseTime= toZip[i*6+5]

      question = Question.find_by(class_period_id: class_period.id,
        question_index: question_index)
        if question == nil
          question = Question.find_or_create_by(class_period: class_period,
            name: question_name, start: start, stop: stop,
            question_index: question_index, num_seconds: num_seconds,
            response_a: response_a, response_b: response_b, response_c: response_c,
            response_d: response_d, response_e: response_e, correct_a: correct_a,
            correct_b: correct_b, correct_c: correct_c, correct_d: correct_d,
            correct_e: correct_e,
            is_deleted: is_deleted)
          else puts 'uh oh!'
          end
=begin
          if save_votes
            vote = Vote.find_by(clicker_id: clicker_id, question_id: question.id)
            if vote == nil
              vote = Vote.find_or_create_by(clicker_id: clicker_id,
                question: question, num_attempts: num_attempts,
                first_answer_time: first_answer_time, total_time: total_time,
                first_response: first_response, response: response,
                loaned_clicker_to: loaned_clicker_to)
              end
            end
=end

            puts "Question #{question_index} Timetot: #{num_seconds} Start: #{start} Stop: #{stop}"
          end
        end


        def parse_course(root, folder, name, institution, term, year, instructor, save_votes = true, clicker_ignore_file = $CLICKER_IGNORE)
          # Create the course if it doesn't exist
          course = Course.find_by(folder_name: folder)

          if course == nil
            course = Course.find_or_create_by(folder_name: folder, name: name,
              institution: institution, term: term, year: year, instructor: instructor)
            end

            # TODO: copy the Images folder to AWS S3
            # http://docs.aws.amazon.com/AWSRubySDK/latest/AWS/S3.html
=begin
            ignore_hash = YAML.load_file(clicker_ignore_file)
            ignore = Set.new
            if ignore_hash.has_key? folder
              ignore = Set.new(ignore_hash[folder])
            end
            $logger.info("We will ignore these clicker IDs #{ignore.inspect}")
=end
            # Iterate through the sessions
            ignore = Set.new
            ignore_hash = Hash.new
            session_path = "#{root}/#{folder}/raw_clicker/*.csv"
            Dir.glob(session_path) do |session_file|
              if (session_file.include?('Config')|| session_file.include?('RemoteID'))
                next
              end
              parse_CSV(session_file, course, save_votes, ignore)
              #puts session_file
            end

            $logger.info("done with #{folder}")
          end
          #for loop, length of array/6
          #i*6+ 0-5, to access each question
          #i is question index
