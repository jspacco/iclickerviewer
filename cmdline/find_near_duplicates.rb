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

def cq_image?(file)
  return (file.to_s. =~ /_Q\d+\.jpg/) != nil
end

# TODO: generalize and pass a block as a 3rd parameter
def get_image_hash(dir, result)
  # puts "dir #{dir}"
  Dir[dir + '/*'].each do |f|
    # puts "the file is #{f}"
    if File.directory?(f)
      # puts "recurse"
      get_image_hash(f, result)
    elsif cq_image?(f)
      img = Phashion::Image.new f
      result[short_file_name(f)] = img
    end
  end
end

def find_near_duplicates(images)
  result = ''
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
        result += "#{f1} #{f2} #{dist}\n"
      end
    end
  end
  return result
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


#
# Find potential matching questions in a list of courses
#
def find_matching_questions(root, courses)
  # First, find all of the images in each folder
  # Then, do an all-to-all comparison
  # Next, output results into each of the folders
  images = Hash.new
  courses.each do |folder|
    get_image_hash("#{root}/#{folder}", images)
  end
  # Now compare each image to every other image
  result = find_near_duplicates(images)
  # Now put the result into the
  return result
end

def main
  root = '/Users/jspacco/projects/clickers/iclickerviewer/public/courses'
  folders = [ # 'UIC.CS261S17', 'UIC.CS362F16', 'UIC.CS111S16'
    ['KnoxCS141F16-1', 'KnoxCS141W17-2'],
    ['UIC.CS361S17', 'UIC.CS361F15', 'UIC.CS361S16', 'UIC361S17'],
    ['UIC.CS385S16', 'UIC.CS385S16'],
    ['UT.CSC108F16-L0104', 'UT.CSC108F16-L0101', 'UT.CSC108F16-L0102', 'UT.CSC108F14-dan']
  ]
  folders.each do |subfolder|
    res = find_matching_questions(root, subfolder)
    puts res
  end
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
