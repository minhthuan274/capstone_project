class AddTypeOfRequestToBorrowings < ActiveRecord::Migration[5.0]
  def change
    add_column :borrowings, :request, :string, default: "Verify"
  end
end
