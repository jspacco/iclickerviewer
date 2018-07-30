class Question < ApplicationRecord
  belongs_to :class_period
  has_many :matching_questions
  has_many :matched_questions, :through => :matching_questions, :foreign_key => :matching_question_id
  has_many :keyword_question_tags
  has_many :keywords, :through => :keyword_question_tags
end
