class MatchingQuestion < ApplicationRecord
  belongs_to :question
  belongs_to :matched_question, :class_name => "Question", :foreign_key => :matching_question_id

  # is_match field possible values:
  # NIL: suggested match that a human needs to look at (for example an OCR program suggested that two questionsa re the same)
  # 0: identical
  # 1: modified

  # FIXME Add validations to raise an error if we try to update either of these
  #   attributes
  attr_readonly :question_id
  attr_readonly :matching_question_id

  # TODO Cascades on create/update/delete
  after_create :add_mirror
  after_update :update_mirror
  after_destroy :destroy_mirror

  private

  def add_mirror
    # Create mirrored record if it doesn't already exist.
    # Necessary to prevent infinite loops.
    if !MatchingQuestion.find_by(question: self.matched_question, matched_question: self.question)
      mirror = self.dup
      mirror.question_id = self.matched_question.id
      mirror.matching_question_id = self.question.id
      mirror.save
    end
  end

  def update_mirror
    if self.saved_changes?
      # XXX apparently changing mirror does not trigger after_update, so there's
      #   no infinite loop. Not entirely sure how ActiveRecord works here.
      mirror = self.class.find_by(question: matched_question, matched_question: question)
      # TODO copy everything except question/matched_question from self to mirror
      mirror.is_match = self.is_match
      mirror.match_type = self.match_type
      mirror.save
   end
  end
  #
  def destroy_mirror
    mirror = self.class.find_by(question: matched_question, matched_question: question)
    mirror.destroy if mirror && !mirror.destroyed?
  end
end
