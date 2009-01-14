class Module
  def delegate(*methods)
    options = methods.pop
    raise ArgumentError, "Delegation needs a target." unless options.is_a?(Hash) && to = options[:to]

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{method}(*args, &block)
          #{to}.__send__(#{method.inspect}, *args, &block)
        end
      EOS
    end
  end
end