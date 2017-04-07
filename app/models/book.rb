class Book < ApplicationRecord
  
  has_many :borrowings, dependent: :destroy 

  validates  :title,    presence: true, length: { maximum: 100 }
  validates  :year,     presence: true, numericality: { greater_than: 0, 
                                                        less_than:    2017 }
  validates  :quantity, presence: true, numericality: { greater_than: 0 }


  def self.search(search)
    if search 
      where("title LIKE ?", "%#{search}%")    
    else
      all
    end
  end

  # Cuon sach bi muon di, nen giam so luong lai 
  def borrowed
    self.decrement!(:availability)
  end

  def return_book
    self.increment!(:availability)
  end

  def available?
    self.availability > 0
  end

  # Get due time of
  def get_due_time(user)
    Borrowing.find_by(user_id: user.id, book_id: self.id)
             .due_date
  end

  # Checks this book, whichs be borrowed by user, has expried ?
  def has_expired?(user)
    get_due_time(user) < Time.zone.now
  end

  def get_borrowing(user)
    self.borrowings.find_by(user_id: user.id)
  end

end
