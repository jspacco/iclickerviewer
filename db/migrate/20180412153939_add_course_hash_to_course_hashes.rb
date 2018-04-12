class AddCourseHashToCourseHashes < ActiveRecord::Migration[5.1]
  def change
    add_column :course_hashes, :course_hash, :string
  end
end
