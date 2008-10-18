require 'metaid'

Object.class_eval do
  def try(m, *a, &b)
    respond_to?(m) ? send(m, *a, &b) : nil
  end
  
  def with(hash)
    hash.each do |key, value|
      meta_def(key) { hash[key] } unless respond_to?(key)
      meta_def("#{key}=") { |v| hash[key] = v } unless respond_to?("#{key}=")
    end
    
    return unless block_given?

    result = yield

    hash.each do |key, value|
      meta_eval { remove_method(key) }
      meta_eval { remove_method("#{key}=") }
    end

    result
  end

  class Object
    def instance_exec(*arguments, &block)
      block.bind(self)[*arguments]
    end
  end
end