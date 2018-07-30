class CreateKeywords < ActiveRecord::Migration[5.2]
  def change
    create_table :keywords do |t|
      t.string :keyword, index: { unique: true }
      t.timestamps
    end

    create_table :keyword_question_tags do |t|
      t.belongs_to :question, index: true
      t.belongs_to :keyword, index: true
      t.belongs_to :user, index: true
    end

    add_index :keyword_question_tags, [:question_id, :keyword_id, :user_id],
      { :unique => true, :name => 'unique_index' }
  end
end
