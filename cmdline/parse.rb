# http://www.nokogiri.org/tutorials/searching_a_xml_html_document.html
require 'rubygems'
require 'nokogiri'
require 'date'
require 'logger'
require_relative 'command_line'

#
# File containing clicker IDs that should be ignored
# FIXME should be configurable from command line or ENV
#
$CLICKER_IGNORE = 'cmdline/clicker_ignore.yml'

# Set up a logger for command-line logging.
$logger = Logger.new(STDOUT)
# TODO set logger level from command line
$logger.level = :info
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'

def get_resp(s)
  # Lots of formats the clickers can use to store this information!
  # No idea why they didn't use two fields. Formats so far include:
  # 2,12.00
  # 2|12.00
  # 96,0
  # 10||25.0
  m = s.match(/(\d+)[^\d]+\d+.*/)
  return m.captures[0].to_i
end

def get_or_nil(val)
  if val == ''
    return nil
  end
  return val
end

def get_datetime(filename)
  # L1609120921.xml
  # L == class_period
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

def parse_XML(filename, course, save_votes, ignore = Array.new)
  # We should ignore these keys:
  # tscr, anspt
  page = Nokogiri::XML(open(filename))
  #puts page.class
  datetime = get_datetime(filename)
  session_code = File.basename(filename, '.xml')
  $logger.debug("%s is the datetime of %s" % [datetime, session_code])
  # Each file should only have one session (class_period) in it
  page.css('//ssn').each do |ssn|
    name = ssn['ssnn']
    $logger.debug("session (class_period) name #{name}")
    min_response = ssn['minrep']
    participation = ssn['part']
    performance = ssn['perf']
    min_response_string = ssn['MinPart_S']
    # Create the class_period if it doesn't exist
    class_period = ClassPeriod.find_by(session_code: session_code)
    if class_period == nil
      class_period = ClassPeriod.find_or_create_by(session_code: session_code,
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
      else
        # We are updating an existing question. This data may have been tagged.
        # XXX DO NOT UPDATE CORRECT ANSWERS! Only update other fields.
        $logger.debug("updating #{question.id} in DB before
        #{question.response_a} #{question.response_b}
        #{question.response_c} #{question.response_d}
        #{question.response_e}".gsub(/\s+/, ' '))

        $logger.debug("just read from file before
        #{response_a} #{response_b} #{response_c} #{response_d} #{response_e}
        ".gsub(/\s+/, ' '))

        # XXX The only fields it makes sense to update right now are the
        #   response fields. If we discover additional data format
        #   inconsistencies, we will take those into account.
        Question.update(question.id,
          :response_a => response_a,
          :response_b => response_b,
          :response_c => response_c,
          :response_d => response_d,
          :response_e => response_e)
        # Remember to reload the question from the DB after an update
        question = Question.find_by(id: question.id)
        $logger.debug("after updating #{question.id} in DB
        after #{question.response_a} #{question.response_b} #{question.response_c}
        #{question.response_d} #{question.response_e}".gsub(/\s+/, ' '))
      end

      # Only parse the votes if we are storing the votes, or if we have
      #   at least one clicker ID that needs to be excluded from the totals.
      if ignore.length > 0 or save_votes
        ignore_a = 0
        ignore_b = 0
        ignore_c = 0
        ignore_d = 0
        ignore_e = 0
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

          if ignore.include?(clicker_id.upcase) || ignore.include?(clicker_id.upcase.gsub(/\#/, ''))
            case response
            when 'A'
              ignore_a += 1
            when 'B'
              ignore_b += 1
            when 'C'
              ignore_c += 1
            when 'D'
              ignore_d += 1
            when 'E'
              ignore_e += 1
            when nil
              $logger.info("No response for #{clicker_id} for #{question.name} in #{class_period.session_code}")
            else
              $logger.error("Unknown clicker response for clicker #{clicker_id}: '#{response}' "+
                "for #{question.name} #{question.question_index} in #{class_period.session_code}")
            end
          end

          # Only include votes if we are storing the votes
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
        end
        # Update the question to ignore responses from clickers that
        #   we have requested to ignore. These clickers might be
        #   students who did not give consent to use their data, or who
        #   were under 18 when they took the course. This depends on the IRB.
        if ignore.length > 0 &&
            ignore_a + ignore_b + ignore_c + ignore_d + ignore_e > 0
          Question.update(question.id,
            response_a: question.response_a - ignore_a,
            response_b: question.response_b - ignore_b,
            response_c: question.response_c - ignore_c,
            response_d: question.response_d - ignore_d,
            response_e: question.response_e - ignore_e)
        end
      end
    end
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

  ignore_hash = YAML.load_file(clicker_ignore_file)
  ignore = Set.new
  if ignore_hash.has_key? folder
    ignore = Set.new(ignore_hash[folder])
  end
  $logger.info("We will ignore these clicker IDs #{ignore.inspect}")
  # Iterate through the sessions
  session_path = "#{root}/#{folder}/SessionData/*.xml"
  Dir.glob(session_path) do |session_file|
    parse_XML(session_file, course, save_votes, ignore)
  end

  $logger.info("done with #{folder}")
end
