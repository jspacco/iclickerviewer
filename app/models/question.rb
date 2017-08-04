class Question < ApplicationRecord
  belongs_to :class_period
  has_many :matching_questions
#  has_many :matched_questions, :through => :matching_questions, :foreign_key => :question_id, :source => :question
#  has_many :matched_questions, :through => :matching_questions, :source => :question
  has_many :matched_questions, :through => :matching_questions, :foreign_key => :matching_question_id

  # has_many :mirror_matching_questions, :class_name => "MatchingQuestion", :foreign_key => "matching_question_id"
  # has_many :mirror_question, :through => :mirror_matching_questions, :source => :question
end
