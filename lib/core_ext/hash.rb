class Hash
  def make_indifferent!
    keys_values = self.dup
    replace(Hash.new { |h,k| h[k.to_s] if Symbol === k })
    merge!(keys_values)
  end
  
  def nest!
    new_params = Hash.new.make_indifferent!
    each_pair do |full_key, value| 
      this_param = new_params
      split_keys = full_key.to_s.split(/\]\[|\]|\[/)
      split_keys.each_index do |index| 
        break if split_keys.length == index + 1 
        this_param[split_keys[index]] ||= Hash.new.make_indifferent!
        this_param = this_param[split_keys[index]] 
      end 
      this_param[split_keys.last] = value 
    end 
    clear
    replace(new_params)
  end
end