class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates  :user_id, presence: true
  validates  :book_id, presence: true

  def verify_borrow_book
    user = User.find_by(id: self.user_id)
    user.borrow_book
    update_columns(verified: true,
                   request:  nil)
  end

  def extend_due_time(days_extend) 
      update_columns(due_time:       self.due_time + days_extend.days,
                     times_extended: self.times_extended + 1,
                     request:        nil)
      self.save
  end

  def update_request_extend(days)
      self.time_extend = days
      self.request = "Extend #{days} days" 
      self.save
  end

  def request_verify_book?
    self.request == "Verify"
  end

  def expired?
    self.due_time > Time.zone.now
  end

  def deny_extend_book
    self.time_extend = nil
    self.request     = nil
    self.save
  end
end
