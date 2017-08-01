require 'set'

def process_pairs(filename)
  done = Set.new
  results = Hash.new
  File.open(filename, 'r') do |f|
    f.each_with_index do |line, index|
      next if index == 0
      f1, f2 = line.strip.split
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

if __FILE__ == $0
  results = process_pairs('OUT3')
  to_html(results, 'file:///Users/jspacco/projects/clickers/iclickerviewer/public/courses')
end

#   done = Set.new
#   File.open("OUT", "r") do |f|
#     line_num = 1
#     f.each_line do |line|
#       row = "<tr><td>#{line_num}</td>"
#       line_num += 1
#       line.strip.split.each do |img|
#         if not done.include?(img)
#           i = img.rindex('/')
#           if i == nil
#             next
#           end
#           row += "<td> <img width=300 src=\"file:///#{img}\"/>"
#           x = img[(i+1)..-1]
#           row += "<br> #{x}</td>"
#           done << img
#         end
#       end
#       puts row + "</tr>"
#     end
#   end
#   puts "</table>"
#   puts "</body></html>"
# end
