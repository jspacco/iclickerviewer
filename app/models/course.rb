class Course < ApplicationRecord
  has_many :class_periods
  has_many :questions, through: :class_periods
  # also has many votes through class_period and question
end
