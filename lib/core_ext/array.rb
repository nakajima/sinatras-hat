class Array
  def extract_options!
    last.is_a?(Hash) ? pop : { }
  end
  
  def move_to_front(*entries)
    entries.each do |entry|
      unshift(entry) if delete(entry)
    end
  end
  
  def move_to_back(*entries)
    entries.each do |entry|
      push(entry) if delete(entry)
    end
  end
end