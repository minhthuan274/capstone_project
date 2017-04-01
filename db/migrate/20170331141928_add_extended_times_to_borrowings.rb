class AddExtendedTimesToBorrowings < ActiveRecord::Migration[5.0]
  def change
    add_column :borrowings, :times_extended, :integer, default: 0
  end
end
