class AddNumberBorrowedBooksToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :number_borrowed_books, :integer, default: 0
  end
end
