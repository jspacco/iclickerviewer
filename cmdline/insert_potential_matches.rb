require 'set'

def process_pairs(filename)
  done = Set.new
  results = Hash.new
  File.open(filename, 'r') do |f|
    f.each_with_index do |line, index|
      next if index == 0
      f1, f2, count = line.strip.split
      if done.include?(f1) and done.include?(f2)
        next
      end
      done << f1
      done << f2
      # make sure f1 comes before f2 alphabetically (not sure if this is necessary)
      if f1 > f2
        f1, f2 = f2, f1
      end
      if not results.has_key?(f1) and not results.has_key?(f2)
        # Have not seen either f1 or f2
        tmp = Set.new [f1, f2]
        results[f1] = tmp
        results[f2] = tmp
      elsif results.has_key?(f1) and not results.has_key?(f2)
        # f1 exists, but f2 does not
        results[f1] << f2
        results[f2] = results[f1]
      elsif not results.has_key?(f1) and results.has_key?(f2)
        # f1 does not, f2 does
        results[f2] << f1
        results[f1] = results[f2]
      else
        # this should never happen!
      end
    end
  end
  return results
end

def to_database(results)
  done = Set.new
  results.each do |f, images|
    images.each do |src|
      images.each do |dst|
        src, dst = dst, src if src > dst
        key = "#{src} #{dst}"
        next if done.include? key
        done << key
        # KnoxCS141F16-1/Images/L1609151005_Q2.jpg
        src_course, src_session_code, src_question_index = src.match(/(.*)\/Images\/(.*)\_Q(\d+)\.jpg/).captures
        dst_course, dst_session_code, dst_question_index = dst.match(/(.*)\/Images\/(.*)\_Q(\d+)\.jpg/).captures

        # course1 = Course.find_by(folder_name: src_course)
        course1 = Course.find_by(folder_name: src_course)
        class_period1 = ClassPeriod.find_by(session_code: src_session_code, course: course1)
        q1 = Question.find_by(class_period: class_period1, question_index: src_question_index)
        if q1 == nil
          puts "missing src #{src_course} #{src_session_code} #{src_question_index}"
          puts "dst #{dst_course} #{dst_session_code} #{dst_question_index}"
        end

        course2 = Course.find_by(folder_name: dst_course)
        class_period2 = ClassPeriod.find_by(session_code: dst_session_code, course: course2)
        q2 = Question.find_by(class_period: class_period2, question_index: dst_question_index)
        if q2 == nil
          puts "src #{src_course} #{src_session_code} #{src_question_index}"
          puts "missing dst #{dst_course} #{dst_session_code} #{dst_question_index}"
        end

        match = MatchingQuestion.find_or_create_by(question: q1, matched_question: q2)
      end
    end
  end
end

def to_html(results, prefix)
  puts "<html><head>"
  puts "</head><body>"
  puts "<table border=1>"
  done = Set.new
  results.each_with_index do |(f, filenames), index|
    if done.include?(f)
      next
    end
    done << f
    puts "<tr>"
    puts "<td>#{index}</td>"
    filenames.each do |filename|
      puts "<td><img width=300 src=\"#{prefix+'/'+filename}\"><br>#{filename}</td>"
      done << filename
    end
    puts "</tr>"
  end
  puts "</table></body></html>"
end

def main
  results = process_pairs('OUT6')
  # to_html(results, 'file:///Users/jspacco/projects/clickers/iclickerviewer/public/courses')
  to_database(results)
end

if __FILE__ == $0
  main
end
