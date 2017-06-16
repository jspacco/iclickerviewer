module ApplicationHelper
  def checked?(val)
    # Helper method to decide if a checkbox should be checked based on its DB value
    if val == '1' || val == 1 || val == true
      return true
    end
    return false
  end
end
