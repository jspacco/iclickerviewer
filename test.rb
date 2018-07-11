def current_time
  return Time.now.to_f
end

def time_code
  start = current_time
  yield
  return current_time - start
end

total = time_code {
  sleep(2)
}

puts "total time is #{total}"
