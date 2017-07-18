class CreateClassPeriods < ActiveRecord::Migration[5.1]
  def change
    create_table :class_periods do |t|
      t.string :session_code
      t.string :name
      t.string :participation
      t.string :performance
      t.string :min_response
      t.string :min_response_string
      t.datetime :date
      t.references :course, foreign_key: true

      t.timestamps
    end
  end
end
