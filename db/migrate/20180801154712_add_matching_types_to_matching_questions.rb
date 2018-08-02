class AddMatchingTypesToMatchingQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :matching_questions, :changed_question_phrasing, :boolean, default: false
    add_column :matching_questions, :changed_question_values, :boolean, default: false
    add_column :matching_questions, :changed_info_phrasing, :boolean, default: false
    add_column :matching_questions, :changed_info_layout, :boolean, default: false
    add_column :matching_questions, :changed_answers_phrasing, :boolean, default: false
    add_column :matching_questions, :changed_answers_values, :boolean, default: false
    add_column :matching_questions, :changed_answers_order, :boolean, default: false
    add_column :matching_questions, :changed_answers_type, :boolean, default: false
    add_column :matching_questions, :changed_other, :boolean, default: false
  end
end
