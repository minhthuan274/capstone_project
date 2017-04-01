module ApplicationHelper

  include SessionsHelper
  include BooksHelper
  include UsersHelper

  
  def full_title(page_title = '')
    base_title = "Capstone app"
    if page_title.empty?
      base_title
    else
      page_title
    end
  end
end
