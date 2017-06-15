class CreateCourses < ActiveRecord::Migration[5.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :term
      t.integer :year
      t.string :institution
      t.string :instructor
      t.string :folder_name

      t.timestamps
    end
  end
end
