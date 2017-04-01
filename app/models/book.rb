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
    self.availability = self.availability - 1
    self.save
  end

  def available?
    self.availability > 0
  end

  def get_due_time(user)
    Borrowing.find_by(user_id: user.id, book_id: self.id)
             .due_time.strftime("%b %d %y")
  end

  def has_expired?(user)
    get_due_time(user) > Time.zone.now
  end
end
