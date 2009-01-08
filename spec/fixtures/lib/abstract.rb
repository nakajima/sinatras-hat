# A fake model class
class Abstract
  class << self
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