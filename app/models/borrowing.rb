class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates  :user_id, presence: true
  validates  :book_id, presence: true

  def verify_borrow_book
    update_columns(verified: true,
                   request:  nil)
  end

  def extend_due_time(days_extend) 
      update_columns(due_time:       self.due_time + days_extend.days,
                     times_extended: self.times_extended + 1,
                     request:        nil)
      self.save
  end

  def update_request_extend(extension_days)
    days = extension_days.to_i
    if self.times_extended == 3
      flash[:warning] = "You extended 3 times. Not allow to extend once more." 
    elsif days <= 0 
      flash[:warning] = "Extension days should be greater than 0"
    elsif days > 14 
      flash[:warning] = "You can't extend more than 2 weeks."
    else
      self.time_extend = days
      self.request = "Extend #{extension_days} days" 
      self.save
    end
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
