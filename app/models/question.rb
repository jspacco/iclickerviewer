class Question < ApplicationRecord
  belongs_to :class_period
  has_many :matching_questions
  has_many :question, :through => :matching_questions

  has_many :inverse_matching_questions, :class_name => "MatchingQuestion", :foreign_key => "matching_question_id"
  has_many :inverse_question, :through => :inverse_matching_questions, :source => :question
end
