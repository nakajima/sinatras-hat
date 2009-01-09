# A fake model class
class Abstract
  class << self
    def create(options={})
      :article
    end
  end
  
  attr_accessor :attributes
  
  def initialize(options={})
    options
  end

  # just like a real ORM ===================
  
  def save
    true
  end
  
  def destroy
    self
  end
end