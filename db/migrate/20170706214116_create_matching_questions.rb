class CreateMatchingQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :matching_questions do |t|
      t.integer :question_id
      t.integer :matching_question_id
      # t.references :question, index: true, foreign_key: true
      # t.references :matching_question, index: true
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
