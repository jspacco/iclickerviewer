class CreateCourseHashes < ActiveRecord::Migration[5.1]
  def change
    create_table :course_hashes do |t|

      t.timestamps
    end
  end
end
