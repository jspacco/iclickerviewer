class CreateMatchingQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :matching_questions do |t|
      t.integer :question_id
      t.integer :matching_question_id
      t.integer :is_match
      t.integer :match_type
      t.timestamps
    end

    add_index :matching_questions,
      [:question_id, :matching_question_id],
      unique: true,
      name: "matching_question_index"
  end
end
