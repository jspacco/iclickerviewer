class Keyword < ApplicationRecord
  has_many :keyword_question_tags
  has_many :questions, :through => :keyword_question_tags
  validates :keyword, presence: true, allow_blank: false
end
