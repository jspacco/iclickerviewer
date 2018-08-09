class AddMatchingTypesToMatchingQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :matching_questions, :changed_question_phrasing, :integer, default: 0
    add_column :matching_questions, :changed_question_values, :integer, default: 0
    add_column :matching_questions, :changed_info_phrasing, :integer, default: 0
    add_column :matching_questions, :changed_info_layout, :integer, default: 0
    add_column :matching_questions, :changed_answers_phrasing, :integer, default: 0
    add_column :matching_questions, :changed_answers_values, :integer, default: 0
    add_column :matching_questions, :changed_answers_order, :integer, default: 0
    add_column :matching_questions, :changed_answers_type, :integer, default: 0
    add_column :matching_questions, :changed_other, :integer, default: 0
  end
end
