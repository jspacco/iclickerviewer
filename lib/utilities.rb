# Put global utility functions here
module Utilities
  def pct_string(num, denom)
    "%s\%" % ((num.to_f / denom.to_f) * 100).round(1).to_s
  end
end
