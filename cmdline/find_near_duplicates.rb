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

def find_near_duplicates(images)
  # matches = Hash.new
  # matches = Set.new
  done = Hash.new
  images.each do |f1, img1|
    images.each do |f2, img2|
      if f1 == f2 or done[f1] == f2 or done[f2] == f1
        next
      end
      # puts "comparing #{f1.gsub(/.*\//, '')} with #{f2.gsub(/.*\//, '')}"
      done[f1] = f2
      done[f2] = f1
      if img1.duplicate? img2
        dist = img1.distance_from(img2)
        puts "#{f1} #{f2} #{dist}"
      end
    end
  end
  # return matches
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

def ocr(dir, result)
  # puts dir
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      ocr(f, result)
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

def ocr2(dir, result)
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      ocr2(f, result)
    elsif image?(f)
      # FIXME: can't get RTesseract to install
      # image = RTesseract.new(f)
      # result[short_file_name(f)] = image.to_s.strip.gsub(/\n/, ' ').gsub(/ +/, ' ') # => 'ABC'
    end
  end
end

def main
  images1 = Hash.new
  folders = [ ['KnoxCS141F16-1', 'KnoxCS141W17-2'],
    # 'UIC.CS261S17', 'UIC.CS362F16', 'UIC.CS111S16'
    ['UIC.CS361S17', 'UIC.CS361F15', 'UIC.CS361S16', 'UIC361S17']
    ['UIC.CS385S16', 'UIC.CS385S16'],
    ['UT.CSC108F16-L0104', 'UT.CSC108F16-L0101', 'UT.CSC108F16-L0102']
  ]
  # get_file_names('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361F16', images)
  # get_file_names('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361S17', images)
  get_file_names('/Users/jspacco/projects/clickers/iclickerviewer/public/courses', images)
  $stderr.puts images.length
  find_near_duplicates(images)
end

if __FILE__ == $0
  main
  # ocr_text = Hash.new
  # # ocr('/Users/jspacco/projects/clickers/iclickerviewer/public/courses/UIC.CS361F16', ocr_text)
  # ocr('/Users/jspacco/projects/clickers/iclickerviewer/public/test', ocr_text)
  # ocr_text.each do |file, text|
  #   puts "#{file} := #{text}"
  # end
end
