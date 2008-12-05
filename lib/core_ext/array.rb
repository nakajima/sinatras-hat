class Array
  def extract_options!
    last.is_a?(Hash) ? pop : { }
  end
  
  def move_to_front(*entries)
    entries.each do |entry|
      if deleted = delete(entry)
        unshift(deleted)
      end
    end
  end
  
  def move_to_back(*entries)
    entries.each do |entry|
      if deleted = delete(entry)
        push(deleted)
      end
    end
  end
end