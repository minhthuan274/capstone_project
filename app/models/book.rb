class Book < ApplicationRecord
  validates  :title,    presence: true, length: { maximum: 100 }
  validates  :year,     presence: true, numericality: { greater_than: 0, 
                                                        less_than:    2017 }
  validates  :quantity, presence: true, numericality: { greater_than: 0 }

end
