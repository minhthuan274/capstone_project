module BorrowingsHelper
  def get_borrowings
    Borrowing.where.not(request: nil)
  end
end
