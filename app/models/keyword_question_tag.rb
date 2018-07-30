class KeywordQuestionTag < ApplicationRecord
  # TODO for some reason, the plural doesn't work here; why not?
  belongs_to :question
  belongs_to :keyword
  belongs_to :user
end
