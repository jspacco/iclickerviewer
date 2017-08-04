class ClassPeriod < ApplicationRecord
  belongs_to :course
  has_many :question
end
