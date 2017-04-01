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
end
