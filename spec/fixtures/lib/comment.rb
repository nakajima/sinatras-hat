class Comment < Abstract
  def self.first(options={})
    :comment
  end

  def self.all
    [:first_comment, :second_comment]
  end
  
  def body
    "I DISAGREE!"
  end
end