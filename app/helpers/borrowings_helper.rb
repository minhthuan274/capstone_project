module BorrowingsHelper
  def get_borrowings
    Borrowing.where("verified LIKE ?", false)
  end
end
