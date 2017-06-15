class CreateVotes < ActiveRecord::Migration[5.1]
  def change
    create_table :votes do |t|
      t.string :clicker_id
      t.float :first_answer_time
      t.float :total_time
      t.integer :num_attempts
      t.string :loaned_clicker_to
      t.string :first_response
      t.string :response
      t.references :question, foreign_key: true

      t.timestamps
    end
  end
end
