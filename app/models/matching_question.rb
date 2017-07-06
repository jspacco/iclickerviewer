class MatchingQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :matching_question, :class_name => "Question"
end
