class Question < ApplicationRecord
  belongs_to :class_period
  has_many :matching_questions
  has_many :matched_questions, :through => :matching_questions, :foreign_key => :matching_question_id

end
