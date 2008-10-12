Array.class_eval do
  def extract_options!
    last.is_a?(Hash) ? pop : { }
  end
end