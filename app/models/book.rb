class Book < ApplicationRecord
  belongs_to :user
  validates  :title, presence: true, length: { maximum: 30 }
  validates  :year,  presence: true, numericality: { greater_than: 0, less_than: 2017 }
end
