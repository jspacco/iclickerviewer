class CreateQuestions < ActiveRecord::Migration[5.1]
  def change
    create_table :questions do |t|
      t.string :name
      t.string :start
      t.string :stop
      t.integer :num_seconds
      t.integer :question_index
      t.integer :response_a
      t.integer :response_b
      t.integer :response_c
      t.integer :response_d
      t.integer :response_e
      t.integer :correct_a
      t.integer :correct_b
      t.integer :correct_c
      t.integer :correct_d
      t.integer :correct_e
      t.string :is_deleted
      t.references :session, foreign_key: true

      t.timestamps
    end
  end
end
