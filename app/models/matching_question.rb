class MatchingQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :matching_question, :class_name => "Question"

  # FIXME Add validations to raise an error if we try to update either of these
  #   attributes
  attr_readonly :question_id
  attr_readonly :matching_question_id

  after_create :add_mirror
  after_update :update_mirror
  after_destroy :destroy_mirror

  private
  
  def add_mirror
    self.class.find_or_create_by(question: matching_question, matching_question: question)
  end

  def update_mirror
    if self.saved_changes?
      # XXX apparently changing mirror does not trigger after_update, so there's
      #   no infinite loop. Not entirely sure how ActiveRecord works here.
      mirror = self.class.find_by(question: matching_question, matching_question: question)
      mirror.is_match = self.is_match
      mirror.match_type = self.match_type
      mirror.save
   end
  end
  #
  def destroy_mirror
    mirror = self.class.find_by(question: matching_question, matching_question: question)
    mirror.destroy if mirror && !mirror.destroyed?
  end
end
