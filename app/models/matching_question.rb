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
    puts "Updating #{self.id}, question_id #{self.question_id}, matching_question_id #{self.matching_question_id}"
    # FIXME On Heroku, this method leads to an infinite loop if we edit existing records.
    # Cannot replicate the error locally. Going to use JS as a temporary fix.
    if self.saved_changes?
      # First, find the mirrored record
      mirror = self.class.find_by(question: matched_question, matched_question: question)
      # Only copy fields other than id, question_id, matching_question_id
      # Probably not the best or most elegant solution, but this loop through
      # all the fields except the ones we don't want works fine.
      copy_fields = MatchingQuestion.new.attributes.keys - ['id', 'question_id', 'matching_question_id']
      copy_fields.each do |field|
        mirror[field] = self[field]
      end
      mirror.save
    else
      puts "No saved changes detected for #{self.id}, question_id #{self.question_id}, matching_question_id #{self.matching_question_id}"
    end
  end
  #
  def destroy_mirror
    mirror = self.class.find_by(question: matched_question, matched_question: question)
    mirror.destroy if mirror && !mirror.destroyed?
  end
end
