class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates  :user_id, presence: true
  validates  :book_id, presence: true

  def verify_borrow_book
    user = User.find_by(id: self.user_id)
    update_columns(verified: true,
                   request:  nil)
  end

  def extend_due_date(days_extend) 
      update_columns(due_date:       self.due_date + days_extend.days,
                     times_extended: self.times_extended + 1,
                     request:        nil,
                     time_extend:    nil,)
  end

  def update_request_extend(days)
      update_columns(time_extend: days,
                     request:     "Extend " + days.to_s + " day".pluralize(days) )
  end

  def request_verify_book?
    self.request == "Verify"
  end

  def expired?
    self.due_date < Time.zone.now
  end

  def deny_extend_book
    self.time_extend = nil
    self.request     = nil
    self.save
  end
end
