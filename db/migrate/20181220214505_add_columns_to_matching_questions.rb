class AddColumnsToMatchingQuestions < ActiveRecord::Migration[5.2]
  def change
    add_column :matching_questions, :changed_slide_presentation, :integer, default: 0
    add_column :matching_questions, :changed_info_added, :integer, default: 0
  end
end
