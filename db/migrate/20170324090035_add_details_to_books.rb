class AddDetailsToBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :books, :quantity,     :integer
    add_column :books, :dewey_id,     :string
    add_column :books, :availability, :integer
  end
end
