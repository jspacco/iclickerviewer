require 'set'
require 'phashion'
# require 'rtesseract'

#
# https://stackoverflow.com/questions/2224379/ruby-on-rails-how-do-you-check-if-a-file-is-an-image
#
#
# pull text out of PDF:
# https://gist.github.com/blazeeboy/9722831
#

def image?(file)
  # (file.to_s.end_with?(".gif") or
  # file.to_s.end_with?(".png") or
  # file.to_s.end_with?(".jpg") or
  # file.to_s.end_with?(".jpeg")) and
  return (file.to_s. =~ /_Q\d+\.jpg/) != nil
end

# TODO: generalize and pass a block as a 3rd parameter
def get_file_names(dir, result)
  # puts "dir #{dir}"
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      get_file_names(f, result)
    elsif image?(f)
      img = Phashion::Image.new f
      result[f] = img
    end
  end
end

# puts image?('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361F16/Images/L1611180856_Q7.jpg')

def main
  images = Hash.new
  get_file_names('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361F16', images)
  get_file_names('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361S17', images)
  puts images.length
  matches = find_near_duplicates(images)
  done = Set.new
  matches.each do |f1, f2|
    if done.include?(f1)
      next
    end
    done << f1
    done << f2
    puts "#{short_file_name(f1)} #{short_file_name(f2)}"
  end
end

def find_near_duplicates(images)
  matches = Hash.new
  done = Hash.new
  images.each do |f1, img1|
    images.each do |f2, img2|
      if f1 == f2 or done[f1] == f2 or done [f2] == f1
        next
      end
      done[f1] = f2
      done[f2] = f1
      if img1.duplicate? img2
        matches[f1] = f2
        matches[f2] = f1
      end
    end
  end
  return matches
end

def short_file_name(filename)
  return filename.match(/([^\/]*\/Images\/.*)/)
end

#
# https://stackoverflow.com/questions/1268289/how-to-get-rid-of-non-ascii-characters-in-ruby
#
$encoding_options = {
  :invalid           => :replace,  # Replace invalid byte sequences
  :undef             => :replace,  # Replace anything not defined in ASCII
  :replace           => '',        # Use a blank for those replacements
  :universal_newline => true,      # Always break lines with \n
  :fallback          => ''         # Replace anything we don't understand with a space
}

def remove_non_ascii(str, replacement="")
  return str.gsub(/[\u0080-\u00ff]/, replacement)
end

def ocr2(dir, result)
  puts dir
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      ocr2(f, result)
    elsif image?(f)
      system("tesseract #{f} output")
      raw_text = File.read('output.txt')
      # ascii = raw_text.encode(Encoding.find('ASCII'), $encoding_options)
      # ascii = raw_text.encode(Encoding.find('ASCII'), $encoding_options)
      begin
        ascii = raw_text.gsub(/\P{ASCII}/, '')
        ascii = ascii.strip.gsub(/\n/, ' ')
        puts "#{f} := #{ascii}"
        # puts ascii
        result[short_file_name(f)] = ascii
      rescue ArgumentError
        $stderr.print
        $stderr.print "non-ascii error in #{f}: #{raw_text}"
      end
    end
  end
end

def ocr(dir, result)
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      ocr(f, result)
    elsif image?(f)
      # FIXME: can't get RTesseract to install
      # image = RTesseract.new(f)
      # result[short_file_name(f)] = image.to_s.strip.gsub(/\n/, ' ').gsub(/ +/, ' ') # => 'ABC'
    end
  end
end

if __FILE__ == $0
  # main
  ocr_text = Hash.new
  ocr2('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361F16', ocr_text)
  ocr_text.each do |file, text|
    puts "#{file} := #{text}"
  end
end
