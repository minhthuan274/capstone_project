class Borrowing < ApplicationRecord
  belongs_to :user
  belongs_to :book
  validates  :user_id, presence: true
  validates  :book_id, presence: true

  def verify_borrow_book
    update_attribute(:verified, true)
  end

  def extend_due_time(due_time) 
    days_extend = due_time.to_i * (24 * 60 * 60)

    if self.times_extended == 3
      flash[:warning] = "You extended 3 times. Not allow to extend once more."
    elsif days_extend > 2.weeks 
      flash[:warning] = "You can't extend more than 2 weeks."
    else
      update_columns(due_time:       self.due_time + days_extend,
                     times_extended: self.times_extended + 1)
      flash[:success] = "Extended successfull"
    end
  end

  def expired?
    self.due_time > Time.zone.now
  end

end
