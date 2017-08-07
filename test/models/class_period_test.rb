require 'test_helper'

class ClassPeriodTest < ActiveSupport::TestCase
  test "find class period" do
    # class_period1 is defined in test/fixtures/class_periods.yml
    class_period1 = ClassPeriod.find_by(session_code: 'class_period1')
    assert class_period1.session_code == 'class_period1'
  end

  test "has many questions" do
    class_period = ClassPeriod.find_by(session_code: 'class_period1')
    assert class_period.questions.length > 0
  end
end
