module ApplicationHelper
  def checked?(val)
    # Helper method to decide if a checkbox should be checked based on its DB value
    if val == '1' || val == 1 || val == true
      return true
    end
    return false
  end

  def data_entered?(question)
    if [4, 5].include?(question.question_type)
      return true
    end
    if [1, 2, 3].include?(question.question_type)
      return question.correct_a + question.correct_b + question.correct_c +
      question.correct_d + question.correct_e != 0
    end
    return false
  end

  def increment(hash, key)
    if not hash.has_key? key
      hash[key] = 0
    end
    hash[key] += 1
  end

  def nil_if_blank(value)
    return nil if value == ''
    return value
  end

  def int_or_nil(value)
    value = nil_if_blank(value)
    value = value.to_i if value
    return value
  end

=begin
Given a list of two values, return them as a string representation
of a fraction. For example, [3, 10] would be "3 / 10"
=end
  def to_s_fraction(values)
    return "#{values[1] - values[0]} / #{values[1]}"
  end

  def is_verified?(user, level)
    if current_user && current_user.verification >= level
      return true
    else
      return false
    end
  end


  def current_time
    return Time.now.to_f
  end

  def get_sql_aggregate_count(sql, col1, col2)
    rows = ActiveRecord::Base.connection.exec_query(sql)
    result = Hash.new
    rows.each do |row|
      result[row[col1]] = row[col2]
    end
    return result
  end

  def output_if_exists(hash, key)
    if hash.key? key
      return "#{hash[key]}"
    else
      return ''
    end
  end

end
