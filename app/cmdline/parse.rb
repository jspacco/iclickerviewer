# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'rubygems'
require 'nokogiri'
require 'date'
require_relative 'command_line'
require_relative '../models/application_record'
require_relative '../models/course'
require_relative '../models/session'
require_relative '../models/question'
require_relative '../models/vote'

def get_resp(s)
  return s[0..(s.index("|")-1)].to_i
end

def get_or_nil(val)
  if val == ''
    return nil
  end
  return val
end

def get_datetime(filename)
  # L1609120921.xml
  # L == session
  # 16 == 2016
  # 0912 == September 12
  # 0921 == 9:21am
  file = File.basename(filename, '.xml')
  m = file.match(/L(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)/)
  year, month, day, hour, minute = m.captures
  return DateTime.new(2000 + year.to_i, month.to_i, day.to_i, hour.to_i, minute.to_i)
end

def get_seconds(time)
  m = time.match(/(\d\d):(\d\d):(\d\d)/)
  hours, minutes, seconds = m.captures
  return hours.to_i * 3600 + minutes.to_i * 60 + seconds.to_i
end

def parse_XML(filename, course)
  # We should ignore these keys:
  # tscr, anspt
  page = Nokogiri::XML(open(filename))
  #puts page.class
  datetime = get_datetime(filename)
  session_code = File.basename(filename, '.xml')
  $logger.debug("%s is the datetime of %s" % [datetime, session_code])
  # Each file should only have one session in it
  page.css('//ssn').each do |ssn|
    name = ssn['ssnn']
    min_response = ssn['minrep']
    participation = ssn['part']
    performance = ssn['perf']
    min_response_string = ssn['MinPart_S']
    # Create the session if it doesn't exist
    session = Session.find_by(session_code: session_code)
    if session == nil
      session = Session.find_or_create_by(session_code: session_code,
        name: name, date: datetime, min_response: min_response,
        participation: participation, performance: performance,
        min_response_string: min_response_string,
        course: course)
    end
    ssn.css('p').each do |prob|
      question_name = prob['qn']
      start = prob['strt']
      stop = prob['stp']
      is_deleted = prob['isDel']

      num_seconds = -1
      if start != '' && stop != ''
        num_seconds = get_seconds(stop) - get_seconds(start)
      end

      question_index = prob['idx'].to_i

      # Number of each response
      response_a = get_resp(prob['resp_a'])
      response_b = get_resp(prob['resp_b'])
      response_c = get_resp(prob['resp_c'])
      response_d = get_resp(prob['resp_d'])
      response_e = get_resp(prob['resp_e'])

      # Essentially a boolean for whether each answer is correct;
      #   necessary since multiple correct answers are possible.
      correct_a = 0
      correct_b = 0
      correct_c = 0
      correct_d = 0
      correct_e = 0

      # Check if instructor set a correct answer during class
      #   (hint: they probably did not)
      correct = prob['cans']
      if correct != ''
        $logger.debug("found a correct answer: %s!" % correct)
        case correct
        when 'A'
          correct_a = 1
        when 'B'
          correct_b = 1
        when 'C'
          correct_c = 1
        when 'D'
          correct_d = 1
        when 'E'
          correct_e = 1
        end
      end

      $logger.debug("%s %d %s %s %d %s" % [question_name, question_index,
        start, stop, num_seconds, correct])
      $logger.debug("%d %d %d %d %d" %
        [response_a, response_b, response_c, response_d, response_e])

      # Create the question if it doesn't exist
      question = Question.find_by(session_id: session.id,
        question_index: question_index)
      if question == nil
        question = Question.find_or_create_by(session: session,
        question_index: question_index, num_seconds: num_seconds,
        response_a: response_a, response_b: response_b, response_c: response_c,
        response_d: response_d, response_e: response_e, correct_a: correct_a,
        correct_b: correct_b, correct_c: correct_c, correct_d: correct_d,
        correct_e: correct_e,
        is_deleted: is_deleted)
      else
        # TODO How do we handle questions that already exist? Update everything
        #   except for the correct answers?
      end

      prob.css('v').each do |vote|
        clicker_id = vote['id']
        loaned_clicker_to = get_or_nil(vote['lto'])
        first_answer_time = get_or_nil(vote['fanst'])
        total_time = get_or_nil(vote['tm'])
        first_response = get_or_nil(vote['fans'])
        response = get_or_nil(vote['ans'])
        num_attempts = 0
        if vote['att'] != ''
          num_attempts = vote['att'].to_i
        end
        $logger.debug("%d %s %s %s %s %s" % [num_attempts, clicker_id,
          first_response, response, first_answer_time, total_time])

        vote = Vote.find_by(clicker_id: clicker_id, question_id: question.id)
        if vote == nil
          vote = Vote.find_or_create_by(clicker_id: clicker_id,
            question: question, num_attempts: num_attempts,
            first_answer_time: first_answer_time, total_time: total_time,
            first_response: first_response, response: response,
            loaned_clicker_to: loaned_clicker_to)
        end
      end
    end
  end
end

def parse_course(root, folder, name, institution, term, year, instructor)
  # Create the course if it doesn't exist
  course = Course.find_by(folder_name: folder)
  if course == nil
    course = Course.find_or_create_by(folder_name: folder, name: name,
      institution: institution, term: term, year: year, instructor: instructor)
  end

  # TODO: copy the Images folder to public/courses/FOLDER/Images

  # Iterate through the sessions
  session_path = "%s/%s/SessionData/*.xml" % [root, folder]
  Dir.glob(session_path) do |session_file|
    parse_XML(session_file, course)
  end
end

if __FILE__ == $0
  root = '/Users/jspacco/projects/clickers/data/'

  # folders = ['UT.CSC108F16-L0101', 'CS141Sec1']

  # parse_course(root, 'UT.CSC108F16-L0101', 'CS1', 'Toronto', 'fall', 2016, 'Petersen')

  parse_course(root, 'UT.CSC108F16-L0102', 'CS1', 'Toronto', 'fall', 2016, 'Petersen')
  p "done with UT.CSC108F16-L0102"
  parse_course(root, 'UT.CSC108F16-L0104', 'CS1', 'Toronto', 'fall', 2016, 'Petersen')
  p "done with UT.CSC108F16-L0104"
  parse_course(root, 'CS141Sec1', 'CS1', 'Knox', 'winter', 2017, 'Spacco')
  p "done with CS141Sec1"

end
