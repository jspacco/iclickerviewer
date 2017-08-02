class Question < ApplicationRecord
  belongs_to :class_period
  has_many :matching_questions
  has_many :question, :through => :matching_questions

  has_many :mirror_matching_questions, :class_name => "MatchingQuestion", :foreign_key => "matching_question_id"
  has_many :mirror_question, :through => :mirror_matching_questions, :source => :question
end
