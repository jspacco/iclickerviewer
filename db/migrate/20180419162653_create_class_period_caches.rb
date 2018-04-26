class CreateClassPeriodCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :class_period_caches do |t|
      t.integer :num_questions
      t.float :avg_secs_question
      t.integer :num_questions_updated
      t.integer :total_class_periods
      t.string :session_code
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
