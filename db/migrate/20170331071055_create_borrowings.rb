class CreateBorrowings < ActiveRecord::Migration[5.0]
  def change
    create_table :borrowings do |t|
      t.references :user, foreign_key: true
      t.references :book, foreign_key: true
      t.integer    :time_extend
      t.datetime   :due_time
      t.boolean    :verified, default: false
      t.timestamps
    end

    add_index :borrowings, [:user_id, :book_id], unique: true
  end
end
