# A fake model class
class Article < Abstract
  def self.first(options={})
    :article
  end

  def self.all
    [:first_article, :second_article]
  end
  
  # fake attributes ========================
  def id
    2
  end
  
  def name
    "The article"
  end
  
  def description
    "This is the article"
  end
  
  # fake association
  def comments
    [Comment.new]
  end
end