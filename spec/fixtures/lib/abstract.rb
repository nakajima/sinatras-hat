# A fake model class
class Abstract
  class << self
    def first(options={})
      :article
    end
  
    def all
      [:first_article, :second_article]
    end
  
    def new(options={})
      options
    end
  
    def create(options={})
      :article
    end
  end

  # just like a real ORM ===================
  
  def save
    true
  end
  
  def destroy
    self
  end
end