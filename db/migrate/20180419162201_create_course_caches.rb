class CreateCourseCaches < ActiveRecord::Migration[5.1]
  def change
    create_table :course_caches do |t|
      t.float :avg_questions_class
      t.float :avg_secs_question
      t.integer :num_classes_updated
      t.integer :total_classes

      t.timestamps
    end
  end
end
