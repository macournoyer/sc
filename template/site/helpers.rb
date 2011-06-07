module Helpers
  def google_analytics_account_id
    'UA-XXXXX-X'
  end
  
  def site_name
    "[Site name, edit in helpers.rb]"
  end
  
  def title
    @title || page.title
  end
  
  def description
    @description || title
  end
end